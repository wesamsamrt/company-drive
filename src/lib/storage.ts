import { mkdir, writeFile, readFile, unlink } from "fs/promises";
import path from "path";
import crypto from "crypto";
const root = path.resolve(process.env.STORAGE_DIR || "storage");
const safeKey = (key: string) => { const value = path.resolve(root, key); if (!value.startsWith(root + path.sep)) throw new Error("مسار تخزين غير صالح"); return value; };
export async function saveFile(file: File, workspaceId: string) { const key = path.join(workspaceId, `${crypto.randomUUID()}-${file.name.replace(/[^\w.\-\u0600-\u06FF]/g, "_")}`); const destination = safeKey(key); await mkdir(path.dirname(destination), { recursive: true }); await writeFile(destination, Buffer.from(await file.arrayBuffer())); return key.replace(/\\/g, "/"); }
export async function getFile(key: string) { return readFile(safeKey(key)); }
export async function removeFile(key: string) { try { await unlink(safeKey(key)); } catch (error: unknown) { if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error; } }
