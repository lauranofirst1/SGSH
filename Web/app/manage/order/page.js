'use client'

import Manage from "../page";
import React, { useEffect, useState } from 'react';
import { supabaseClient } from '@/lib/supabase';


export default function ManageOrder() {
    const [isLoading, setIsLoading] = useState(true);
    const [orders, setOrders] = useState([]);
    // const [tmpOrders, setTmpOrders] = useState([]);

    useEffect(() => {
        var test1;
        var test2;
        const fetchOrders = async () => {
            // const { data } = await supabaseClient.from('order_data').select("*").eq('b_id', 1).order("id", { ascending: false });
            // setOrders(data)
            // setIsLoading(false)
            const { data } = await supabaseClient.from('order_data').select("*").eq('b_id', 1).order("id", { ascending: false });
            test1 = data;
        }
        fetchOrders()

        const intervalId = setInterval(async () => {
            const { data } = await supabaseClient.from('order_data').select("*").eq('b_id', 1).order("id", { ascending: false });
            setOrders(data)
            test2 = data;
            setIsLoading(false)
            if (test1.length != test2.length) {
                beep();
                test1 = test2;
            }
        }, 1000);
        return () => clearInterval(intervalId);
    }, [])


    function beep() {
        var snd = new Audio("data:audio/wav;base64,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qJrx4KOQjahZxWbcZgztj2c49nKmkId44S71j0c8eV9yDK6uPRzx5X18eDvjvQ6yKo9ZSS6l//8elePK/Lf//IInrOF/FvDoADYAGBMGb7FtErm5MXMlmPAJQVgWta7Zx2go+8xJ0UiCb8LHHdftWyLJE0QIAIsI+UbXu67dZMjmgDGCGl1H+vpF4NSDckSIkk7Vd+sxEhBQMRU8j/12UIRhzSaUdQ+rQU5kGeFxm+hb1oh6pWWmv3uvmReDl0UnvtapVaIzo1jZbf/pD6ElLqSX+rUmOQNpJFa/r+sa4e/pBlAABoAAAAA3CUgShLdGIxsY7AUABPRrgCABdDuQ5GC7DqPQCgbbJUAoRSUj+NIEig0YfyWUho1VBBBA//uQZB4ABZx5zfMakeAAAAmwAAAAF5F3P0w9GtAAACfAAAAAwLhMDmAYWMgVEG1U0FIGCBgXBXAtfMH10000EEEEEECUBYln03TTTdNBDZopopYvrTTdNa325mImNg3TTPV9q3pmY0xoO6bv3r00y+IDGid/9aaaZTGMuj9mpu9Mpio1dXrr5HERTZSmqU36A3CumzN/9Robv/Xx4v9ijkSRSNLQhAWumap82WRSBUqXStV/YcS+XVLnSS+WLDroqArFkMEsAS+eWmrUzrO0oEmE40RlMZ5+ODIkAyKAGUwZ3mVKmcamcJnMW26MRPgUw6j+LkhyHGVGYjSUUKNpuJUQoOIAyDvEyG8S5yfK6dhZc0Tx1KI/gviKL6qvvFs1+bWtaz58uUNnryq6kt5RzOCkPWlVqVX2a/EEBUdU1KrXLf40GoiiFXK///qpoiDXrOgqDR38JB0bw7SoL+ZB9o1RCkQjQ2CBYZKd/+VJxZRRZlqSkKiws0WFxUyCwsKiMy7hUVFhIaCrNQsKkTIsLivwKKigsj8XYlwt/WKi2N4d//uQRCSAAjURNIHpMZBGYiaQPSYyAAABLAAAAAAAACWAAAAApUF/Mg+0aohSIRobBAsMlO//Kk4soosy1JSFRYWaLC4qZBYWFRGZdwqKiwkNBVmoWFSJkWFxX4FFRQWR+LsS4W/rFRb/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////VEFHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU291bmRib3kuZGUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMjAwNGh0dHA6Ly93d3cuc291bmRib3kuZGUAAAAAAAAAACU=");
        snd.play();
        snd.addEventListener("ended", function () {
            snd.currentTime = 0;
            snd.play();
            snd.addEventListener("ended", function () {
                snd.currentTime = 0;
                snd.play();
            }, { once: true });
        }, { once: true });
    }

    async function checkOrder(id) {
        console.log(id);
        const { error } = await supabaseClient
            .from('order_data')
            .update({ status: 'check' })
            .eq('id', parseInt(id))

        const { data } = await supabaseClient.from('order_data').select("*").eq('b_id', 1).order("id", { ascending: false });
        setOrders(data)
    }
    async function cancelOrder(id) {
        console.log(id);
        const { error } = await supabaseClient
            .from('order_data')
            .update({ status: 'cancel' })
            .eq('id', id)

        const { data } = await supabaseClient.from('order_data').select("*").eq('b_id', 1).order("id", { ascending: false });
        setOrders(data)
    }

    return (
        <Manage>
            <div className="w-full p-4 md:ml-64">
                <div className="p-4 border-2 border-gray-200 border-dashed rounded-lg dark:border-gray-700">
                    <h2 className="mb-5 font-bold text-xl text-3xl mb-2 text-black">주문 관리</h2>
                    {isLoading ?
                        <div className="flex flex-row mx-auto my-20 md:-my-20 h-screen justify-center md:items-center">
                            <div className="w-40 h-40 rounded-full animate-spin 
                        border-2 border-solid border-blue-500 border-t-transparent"></div>
                        </div>
                        :
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 mt-4">
                            {orders.length == 0 &&
                                <div>
                                    <p>현재 주문 데이터가 없습니다</p>
                                </div>}
                            {orders.map((order) => {
                                var tmpName = order.name.split(",");
                                var tmpPrice = order.price.split(",");
                                var tmpCount = order.count.split(",");
                                var totalAmount = 0;
                                for (let i = 0; i < tmpPrice.length - 1; i++) {
                                    totalAmount += parseInt(tmpPrice[i]) * parseInt(tmpCount[i]);
                                }
                                return (
                                    <div key={order.id} className="flex flex-col justify-between p-2 border-2 rounded-xl">
                                        <div>
                                            <div className="flex justify-between mb-4">
                                                <p className="font-bold">{order.table_no}번 테이블</p>
                                                <p>{order.time.substring(5)}</p>
                                            </div>
                                            {tmpName.map((menuName, index) => menuName.length != 0 &&
                                                <div key={index} className="flex justify-between">
                                                    <p>{menuName}</p>
                                                    <p className="font-bold">{tmpCount[index]}개</p>
                                                </div>)}
                                        </div>

                                        <div className="mt-4 mb-2">
                                            <div className="flex justify-between mb-2 mx-2">
                                                {order.status == "order" && <p className="text-blue-500 font-bold">주문 대기</p>}
                                                {order.status == "check" && <p className="text-green-500 font-bold">주문 확인</p>}
                                                {order.status == "cancel" && <p className="text-red-500 font-bold">주문 취소</p>}
                                                <p className="font-bold">{totalAmount.toLocaleString()}원</p>
                                            </div>
                                            <div className="flex items-center">
                                                {
                                                    order.status == "order" &&
                                                    <div className="flex w-full">
                                                        <button onClick={() => checkOrder(order.id)} className="flex-1 px-4 py-2 bg-green-100 font-bold rounded-l-lg">확인</button>
                                                        <button onClick={() => cancelOrder(order.id)} className="flex-1 px-4 py-2 bg-red-100 font-bold rounded-r-lg">취소</button>
                                                    </div>
                                                }
                                                {
                                                    order.status == "check" &&
                                                    <div className="flex w-full">
                                                        <button className="flex-1 px-4 py-2 bg-green-100 font-bold rounded-lg" disabled>확인</button>
                                                    </div>
                                                }
                                                {
                                                    order.status == "cancel" &&
                                                    <div className="flex w-full">
                                                        <button className="flex-1 px-4 py-2 bg-red-100 font-bold rounded-lg" disabled>취소</button>
                                                    </div>
                                                }
                                            </div>

                                        </div>
                                    </div>
                                )
                            })}

                        </div>
                    }
                </div>
            </div>
        </Manage>
    );
}