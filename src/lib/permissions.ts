import { WorkspaceRole } from "@prisma/client";
export type Capability = "view" | "download" | "upload" | "edit" | "delete" | "createFolder" | "deleteFolder" | "invite" | "manageMembers" | "deleteWorkspace";
const allowed: Record<WorkspaceRole, Capability[]> = {
  OWNER: ["view","download","upload","edit","delete","createFolder","deleteFolder","invite","manageMembers","deleteWorkspace"],
  ADMIN: ["view","download","upload","edit","delete","createFolder","deleteFolder","invite","manageMembers"],
  EDITOR: ["view","download","upload","edit","createFolder"],
  VIEWER: ["view","download"]
};
export const can = (role: WorkspaceRole, capability: Capability) => allowed[role].includes(capability);
export const canManageRole = (actor: WorkspaceRole, target: WorkspaceRole) => actor === "OWNER" || (actor === "ADMIN" && target !== "OWNER" && target !== "ADMIN");
