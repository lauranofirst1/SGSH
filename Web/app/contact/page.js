'use client'

import { supabaseClient } from "@/lib/supabase";
import { useState } from "react";


export default function Contact() {
    const [isLoading, setIsLoading] = useState(false);
    const [enrollData, setEnrollData] = useState({
        name: '',
        b_name: '',
        contact: '',
        address: '',
    });

    const handleInputChange = (e) => {
        setEnrollData({ ...enrollData, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setIsLoading(true);

        const { data: enroll, error: enrollError } = await supabaseClient
            .from("contact_data")
            .insert([
                {
                    name: enrollData.name,
                    b_name: enrollData.b_name,
                    contact: enrollData.contact,
                    address: enrollData.address,
                },
            ]);
        location.reload();
    };
    return (
        <div className="flex flex-col justify-center items-center">

            {isLoading ?
                <div className="flex flex-row mx-auto my-20 md:-my-20 h-screen justify-center md:items-center">
                    <div className="w-40 h-40 rounded-full animate-spin 
                            border-2 border-solid border-blue-500 border-t-transparent"></div>
                </div>
                :
                <div className="flex flex-col justify-center items-center w-full max-w-xl p-[60px]">
                    <p className="text-xl font-bold">서비스 가입하기</p>

                    <hr className="w-full my-10 border-3 border-gray-200 rounded" />
                    <form onSubmit={(e) => { handleSubmit(e) }} className="w-full">
                        <div className="w-full mb-5">
                            <label htmlFor="name" className="block mb-2 font-black">대표명</label>
                            <input type="text" id="name" name="name" placeholder="" onChange={handleInputChange} required className="border border-gray-300 shadow p-3 w-full rounded-lg" />
                        </div>

                        <div className="w-full mb-5">
                            <label htmlFor="name" className="block mb-2 font-black">업체명</label>
                            <input type="text" id="b_name" name="b_name" placeholder="" onChange={handleInputChange} required className="border border-gray-300 shadow p-3 w-full rounded-lg" />
                        </div>

                        <div className="w-full mb-5">
                            <label htmlFor="name" className="block mb-2 font-black">연락처</label>
                            <input type="text" id="contact" name="contact" placeholder="" onChange={handleInputChange} required className="border border-gray-300 shadow p-3 w-full rounded-lg" />
                        </div>

                        <div className="w-full mb-5">
                            <label htmlFor="name" className="block mb-2 font-black">주소</label>
                            <input type="text" id="address" name="address" placeholder="" onChange={handleInputChange} required className="border border-gray-300 shadow p-3 w-full rounded-lg" />
                        </div>

                        <div className="w-full mb-5 flex flex-row gap-4 items-center">
                            <input type="checkbox" className="border-gray-300 rounded h-5 w-5" required />
                            <p className="text-gray-600 font-black text-sm md:text-base">개인정보 수집 및 이용에 동의합니다.</p>
                        </div>
                        <button type='submit' className="w-full mt-5 px-10 py-3 bg-purple-600 rounded-lg text-white text-lg font-extrabold">가입하기</button>
                    </form>
                </div>}
        </div>
    )
}