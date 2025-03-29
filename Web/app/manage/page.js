'use client'

import ManageInfo from "@/components/feature/manage_info";
import ManageNavBar from "@/components/feature/manage_navbar";
import ManageSideBar from '@/components/feature/manage_sidebar';
import { usePathname } from "next/navigation";

export default function Manage({children}) {
    const pathname = usePathname();
    return (
        <>
            <ManageNavBar />
            <div className="flex flex-row">
                <ManageSideBar />
                {pathname == ("/manage") ? 
                    <ManageInfo />
                : null}
                { children }
            </div>
        </>
    );
}