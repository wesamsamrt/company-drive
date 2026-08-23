import { SignJWT, jwtVerify } from "jose";
import { cookies } from "next/headers";
import { NextRequest } from "next/server";

const COOKIE = "company_drive_session";
const key = () => new TextEncoder().encode(process.env.AUTH_SECRET || "development-secret-change-me-32-chars");
export type Session = { id: string; name: string; email: string };
export async function createToken(user: Session) { return new SignJWT(user).setProtectedHeader({ alg: "HS256" }).setIssuedAt().setExpirationTime("7d").sign(key()); }
export async function readToken(token?: string): Promise<Session | null> { try { if (!token) return null; const { payload } = await jwtVerify(token, key()); return { id: String(payload.id), name: String(payload.name), email: String(payload.email) }; } catch { return null; } }
export async function currentUser() { const token = (await cookies()).get(COOKIE)?.value; return readToken(token); }
export async function requestUser(request: NextRequest) { return readToken(request.cookies.get(COOKIE)?.value); }
export const sessionCookie = (token: string) => ({ name: COOKIE, value: token, httpOnly: true, sameSite: "lax" as const, secure: process.env.NODE_ENV === "production", path: "/", maxAge: 60 * 60 * 24 * 7 });
export const clearSessionCookie = { name: COOKIE, value: "", path: "/", maxAge: 0 };
