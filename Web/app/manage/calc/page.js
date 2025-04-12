'use client'

import Manage from "../page";
import ManageNavBar from "@/components/feature/manage_navbar";
import React, { useEffect, useState } from 'react';

export default function ManageCalc() {
    // 콤마 추가
    const [calcDataC, setCalcDataC] = useState({
        매출: "17,000,000",
        원가: "6,000,000",
        임대료: "2,500,000",
        관리비: "510,000",
        급여비: "2,800,000",
        수수료: "400,000",
    });
    const [calcData, setCalcData] = useState({
        매출: 17000000,
        원가: 6000000,
        임대료: 2500000,
        관리비: 510000,
        급여비: 2800000,
        수수료: 400000,
    });

    const handleInputChange = (e) => {
        const value = e.target.value;
        const onlyNums = value.replace(/[^0-9]/g, '');
        const withCommas = onlyNums.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        setCalcDataC({ ...calcDataC, [e.target.name]: withCommas });
        setCalcData({ ...calcData, [e.target.name]: parseInt(onlyNums) });
    };

    return (
        <Manage>
            <div className="w-full md:ml-64">
                <ManageNavBar />
                <div className="p-4">
                    <div className="p-4 border-2 border-gray-200 border-dashed rounded-lg dark:border-gray-700">
                        <h2 className="mb-5 font-bold text-xl text-3xl mb-10 text-black">매출 계산기</h2>
                        <div className="lg:flex mb-4">
                            <div className="px-6">
                                <div className="grid grid-cols-1 lg:grid-cols-2 gap-x-8 gap-y-6 lg:gap-y-10">
                                    <div className="rounded">
                                        <label htmlFor="name" className="text-green-800 block mb-2 font-black text-lg">예상 월 매출</label>
                                        <input type="text" inputMode="numeric" pattern="\d*" value={calcDataC.매출} onChange={handleInputChange} name="매출" placeholder="" required className="text-right font-black text-lg border border-gray-300 shadow p-3 w-full h-16 rounded-lg" />
                                    </div>
                                    <div className="rounded">
                                        <label htmlFor="name" className="text-green-800 block mb-2 font-black text-lg">원가</label>
                                        <input type="text" inputMode="numeric" pattern="\d*" value={calcDataC.원가} onChange={handleInputChange} name="원가" placeholder="" required className="font-black text-right text-lg border border-gray-300 shadow p-3 w-full h-16 rounded-lg" />
                                    </div>
                                    <div className="rounded">
                                        <label htmlFor="name" className="text-green-800 block mb-2 font-black text-lg">임대료</label>
                                        <input type="text" inputMode="numeric" pattern="\d*" value={calcDataC.임대료} onChange={handleInputChange} name="임대료" placeholder="" required className="font-black text-right text-lg border border-gray-300 shadow p-3 w-full h-16 rounded-lg" />
                                    </div>
                                    <div className="rounded">
                                        <div className="flex gap-1">
                                            <label htmlFor="name" className="text-green-800 block mb-2 font-black text-lg">관리비</label>
                                            <div className="mt-1 relative flex flex-col items-center group">
                                                <svg className="w-5 h-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="#999">
                                                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z" clipRule="evenodd" />
                                                </svg>
                                                <div className="absolute left-0 bottom-3 flex flex-col items-start hidden mb-5 group-hover:flex w-max">
                                                    <span className="relative rounded-md z-10 p-4 leading-7 text-base text-white font-black whitespace-no-wrap bg-gray-500 shadow-lg">관리비는 전기요금, 수도요금, 가스요금, 건물 관리비와 같이<br />점포를 운영하는 데 필요한 비용이에요.</span>
                                                    <div className="ml-1 w-3 h-3 -mt-2 rotate-45 bg-gray-500"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <input type="text" inputMode="numeric" pattern="\d*" value={calcDataC.관리비} onChange={handleInputChange} name="관리비" placeholder="" required className="text-right font-black text-lg border border-gray-300 shadow p-3 w-full h-16 rounded-lg" />
                                    </div>
                                    <div className="rounded">
                                        <div className="flex gap-1">
                                            <label htmlFor="name" className="text-green-800 block mb-2 font-black text-lg">급여비</label>
                                            <div className="mt-1 relative flex flex-col items-center group">
                                                <svg className="w-5 h-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="#999">
                                                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z" clipRule="evenodd" />
                                                </svg>
                                                <div className="absolute left-0 bottom-3 flex flex-col items-start hidden mb-5 group-hover:flex w-max">
                                                    <span className="relative rounded-md z-10 p-4 leading-7 text-base text-white font-black whitespace-no-wrap bg-gray-500 shadow-lg">2025년 월 최저임금 2,096,270원<br />(주 40시간, 주휴시간 35시간 포함 209시간)</span>
                                                    <div className="ml-1 w-3 h-3 -mt-2 rotate-45 bg-gray-500"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <input type="text" inputMode="numeric" pattern="\d*" value={calcDataC.급여비} onChange={handleInputChange} name="급여비" placeholder="" required className="text-right font-black text-lg border border-gray-300 shadow p-3 w-full h-16 rounded-lg" />
                                    </div>
                                    <div className="rounded">
                                        <div className="flex gap-1">
                                            <label htmlFor="name" className="text-green-800 block mb-2 font-black text-lg">수수료</label>
                                            <div className="mt-1 relative flex flex-col items-center group">
                                                <svg className="w-5 h-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="#999">
                                                    <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z" clipRule="evenodd" />
                                                </svg>
                                                <div className="absolute left-0 bottom-3 flex flex-col items-start hidden mb-5 group-hover:flex w-max">
                                                    <span className="relative rounded-md z-10 p-4 leading-7 text-base text-white font-black whitespace-no-wrap bg-gray-500 shadow-lg">수수료는 로열티, 광고비, 신용카드 수수료와 같이<br />매출에 따라 발생하는 비용이에요.</span>
                                                    <div className="ml-1 w-3 h-3 -mt-2 rotate-45 bg-gray-500"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <input type="text" inputMode="numeric" pattern="\d*" value={calcDataC.수수료} onChange={handleInputChange} name="수수료" placeholder="" required className="text-right font-black text-lg border border-gray-300 shadow p-3 w-full h-16 rounded-lg" />
                                    </div>
                                </div>
                            </div>
                            <div className="mx-6 mt-10 lg:mt-0 p-4 border font-bold rounded-lg">
                                <p>예상 월 매출이 {calcDataC.매출}원 일 때,</p>
                                <p className="mt-2">수익률은 약 <span className="font-extrabold text-blue-600">{Math.round((calcData.매출 - calcData.원가 - calcData.임대료 - calcData.관리비 - calcData.급여비 - calcData.수수료) / calcData.매출 * 100)}%</span></p>
                                <p className="mt-2">월 수익은</p>
                                <p className="mt-2">약 <span className="font-extrabold text-blue-600">{(calcData.매출 - calcData.원가 - calcData.임대료 - calcData.관리비 - calcData.급여비 - calcData.수수료).toLocaleString()}원</span>입니다</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </Manage>
    );
}