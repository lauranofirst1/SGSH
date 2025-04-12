'use client'

import ManageInfo from "@/components/feature/manage_info";
import ManageSideBar from '@/components/feature/manage_sidebar';
import { usePathname } from "next/navigation";

export default function Manage({ children }) {
    const pathname = usePathname();
    return (
        <>
            <div className="flex flex-row min-h-screen bg-[#f9fafb]">
                <ManageSideBar />
                {pathname == ("/manage") ?
                    <ManageInfo />
                    : null}
                {children}
            </div>
        </>
    );
}