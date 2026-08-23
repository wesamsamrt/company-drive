"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { Shell } from "./Shell";
export function ActivityClient({ workspaceId, name }: { workspaceId: string; name: string }) {
  const [items, setItems] = useState<any[]>([]);
  useEffect(() => { fetch(`/api/workspaces/${workspaceId}/activity`).then(r => r.ok ? r.json() : []).then(setItems); }, [workspaceId]);
  return <Shell name={name}><Link className="muted" href={`/workspaces/${workspaceId}`}>← العودة لمساحة العمل</Link><h1>سجل النشاط</h1><div className="card" style={{padding: 8}}>{items.map(item => <div key={item.id} style={{padding: 12, borderBottom: "1px solid #e6eeec"}}><b>{item.actor.name}</b> {item.action} <b>{item.entityName}</b><span className="muted" style={{marginRight: 10}}>{new Date(item.createdAt).toLocaleString("ar-SA")}</span></div>)}{!items.length && <p className="muted" style={{padding:12}}>لا توجد عمليات مسجلة بعد.</p>}</div></Shell>;
}
