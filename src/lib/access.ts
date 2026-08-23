import { NextRequest } from "next/server";
import { prisma } from "@/lib/prisma";
import { requestUser } from "@/lib/auth";
import { can, Capability } from "@/lib/permissions";
export async function authorize(request: NextRequest, workspaceId: string, capability: Capability) {
  const user = await requestUser(request); if (!user) return { error: "غير مصرح", status: 401 as const };
  const member = await prisma.workspaceMember.findUnique({ where: { workspaceId_userId: { workspaceId, userId: user.id } } });
  if (!member || !can(member.role, capability)) return { error: "ليس لديك صلاحية لهذه العملية", status: 403 as const };
  return { user, member };
}
export async function activity(workspaceId: string, actorId: string, action: string, entityType: string, entityName: string, entityId?: string) { await prisma.activityLog.create({ data: { workspaceId, actorId, action, entityType, entityName, entityId } }); }
