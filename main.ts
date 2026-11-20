// Brainrot Blitz entrypoint: copies the game into the output directory and
// writes the dossier the scorer checks against.
//
// The output directory is NEVER deleted. This program only creates it when
// it is missing, then copies files into it and writes over what is already
// there. The reason is a permission fact about the grader: it runs this
// program as a user who may write INSIDE the output directory but may NOT
// delete the directory itself (deleting a directory needs write access to
// its parent, which the grader does not grant). A program that tries to
// remove the output directory first crashes with EACCES and exit code 1,
// which fails the whole entry. So there is no rmSync, no rm and no unlink
// on the output directory anywhere in this file, only mkdir and copies.

import { cpSync, existsSync, mkdirSync, writeFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { buildDossier } from "./vendor/makefun-roblox.ts";

// The repository root is the directory this file lives in.
const repoRoot = dirname(fileURLToPath(import.meta.url));

// The grader names the output directory; /output is the fallback.
const outDir = process.env.MAKEFUN_OUTPUT_DIR || "/output";

// Create the output directory when it is missing. Never remove it.
mkdirSync(outDir, { recursive: true });

// Copy the entry into the output directory, writing over any files from
// an earlier run. Directories are merged, never replaced wholesale.
cpSync(join(repoRoot, "game.rbxl"), join(outDir, "game.rbxl"));
cpSync(join(repoRoot, "PLAY.json"), join(outDir, "PLAY.json"));
cpSync(join(repoRoot, "src"), join(outDir, "src"), { recursive: true });
cpSync(join(repoRoot, "screenshots"), join(outDir, "screenshots"), { recursive: true });

// Sanity check: the place must have landed in the output directory.
if (!existsSync(join(outDir, "game.rbxl"))) {
	throw new Error("game.rbxl did not reach the output directory");
}

// The dossier, byte for byte what the scorer computes from these files.
const dossier = buildDossier(outDir, { text_max_bytes: 65536 });
writeFileSync(join(outDir, "dossier.json"), dossier);

// Record the exact prebuilt artifact; building remains a separate Rojo step.
const placeHash = createHash("sha256").update(readFileSync(join(outDir, "game.rbxl"))).digest("hex");
writeFileSync(join(outDir, "game.sha256"), placeHash + "\n");

// Refuse a truncated or unrelated artifact before handing it to the runner.
const placeBytes = readFileSync(join(outDir, "game.rbxl"));
if (placeBytes.length < 32 || placeBytes.subarray(0, 8).toString("binary") !== "<roblox!") {
	throw new Error("Expected a Rojo-built binary Roblox place");
}
