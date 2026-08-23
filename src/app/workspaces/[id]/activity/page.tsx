import { redirect } from "next/navigation";
import { currentUser } from "@/lib/auth";
import { ActivityClient } from "@/components/ActivityClient";
export default async function Page({ params }: { params: Promise<{ id: string }> }) { const user = await currentUser(); if (!user) redirect("/login"); const { id } = await params; return <ActivityClient workspaceId={id} name={user.name} />; }
