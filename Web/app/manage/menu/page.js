'use client'

import Manage from "../page";
import { supabaseClient } from '@/lib/supabase';
import React, { useEffect, useState, useRef } from 'react';
import Image from 'next/image';

export default function ManageMenu() {

    const photoInput = useRef(null);

    const [isLoading, setIsLoading] = useState(true);
    const [image, setImage] = useState(null);
    const [menus, setMenus] = useState([]);
    const [showModal, setShowModal] = useState(false);
    const [showEditModal, setShowEditModal] = useState(false);
    const [dateFormat, setDateFormat] = useState();
    const [photoToAddList, setPhotoToAddList] = useState([]);


    const [menuData, setMenuData] = useState({
        menu_image: '',
        menu_name: '',
        menu_price: 0,
        menu_description: ''
    });

    const [menuEditData, setMenuEditData] = useState({
        edit_id: 0,
        edit_name: '',
        edit_description: '',
        edit_price: 0,
    })
    const { menu_image, menu_name, menu_price, menu_description } = menuData;
    const { edit_id, edit_name, edit_description, edit_price } = menuEditData;

    const handleInputImageChange = (e) => {
        if (e.target.files != null) {
            setImage(e.target.files[0]);
            menuData.menu_image = "https://cytktlrbanxiswqurqth.supabase.co/storage/v1/object/public/images/menu_images/" + String(1) + "/" + dateFormat + encodeFilename(e.target.files[0].name);
            console.log(menuData.menu_image);
            setPhotoToAddList(URL.createObjectURL(e.target.files[0]));
        }
    };

    const handleInputChange = (e) => {
        setMenuData({ ...menuData, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (image != null) {
            const { data: uploadImage, error: uploadImageError } = await supabaseClient.storage.from("images").upload("menu_images/" + String(1) + "/" + dateFormat + encodeFilename(image?.name), image);
            if (uploadImage) {
                // console.log("uploadImage");
                // console.log(uploadImage);
            } else if (uploadImageError) {
                console.log("uploadImageError");
                console.log(uploadImageError);
            }
        }

        const { data: addMenu, error: addMenuError } = await supabaseClient
            .from("menu_data")
            .insert([
                {
                    b_id: 1,
                    name: menu_name,
                    price: menu_price,
                    description: menu_description,
                    image: menu_image,
                },
            ]);

        if (addMenu) {
            // console.log("addMenu" + " " + menuData.menu_image);
            // setMenus({
            //     cafe_id: 4,
            //     image: menu_image,
            //     name: menu_name,
            //     price: menu_price,
            // })

        } else if (addMenuError) {
            // console.log("addMenuError");
        }

        setMenus([...menus, {
            b_id: 1,
            name: menu_name,
            price: menu_price,
            description: menu_description,
            image: menu_image,
        }])

        closeModal();
    };


    useEffect(() => {
        const fetchMenus = async () => {
            const { data } = await supabaseClient.from('menu_data').select("*").eq('b_id', 1).order("id", { ascending: true });
            setMenus(data)
            setIsLoading(false)
        }

        fetchMenus()
    }, [])

    function openModal() {
        let date = new Date();
        setDateFormat(date.getFullYear().toString() + ("0" + (date.getMonth() + 1)).slice(-2) + ("0" + date.getDate()).slice(-2) + date.getHours() + date.getMinutes() + date.getSeconds());
        setShowModal(true);
    }

    function closeModal() {
        menuData.menu_image = "";
        menuData.menu_name = "";
        menuData.menu_price = 0;
        setShowModal(false);
    }

    function openEditModal(e) {
        setPhotoToAddList(e.image);
        setMenuEditData({
            edit_id: e.id,
            edit_name: e.name,
            edit_description: e.description,
            edit_price: e.price,
        })
        setShowEditModal(true);
    }
    function closeEditModal() {
        menuEditData.edit_id = 0;
        menuEditData.edit_name = "";
        menuEditData.edit_description = "";
        menuEditData.edit_price = 0;
        menuEditData.edit_composition = "";
        menuEditData.edit_time = "";
        setShowEditModal(false);
    }

    // 추가 상품 입력 수정
    const handleEditInputChange = (e) => {
        setMenuEditData({ ...menuEditData, [e.target.name]: e.target.value });
    };

    const numberInputOnWheelPreventChange = (e) => {
        e.target.blur()
        e.stopPropagation()
        setTimeout(() => {
            e.target.focus()
        }, 0)
    }

    const photoToAddPreview = () => {
        return (
            <Image
                className="h-60"
                src={photoToAddList}
                alt={''}
                width={500}
                height={500}
                style={{ objectFit: "cover" }}>
            </Image>

        )

    };


    // 기본 상품 수정 업데이트
    const handleEditSubmit = async (e) => {
        e.preventDefault();

        if (image != null) {
            const { data: uploadImage, error: uploadImageError } = await supabaseClient.storage.from("images").upload("menu_images/" + String(1) + "/" + encodeFilename(image?.name), image);
            if (uploadImage) {
                // console.log("uploadImage");
            } else if (uploadImageError) {
                // console.log(uploadImageError);
            }
        }

        const { data: addMenu, error: addMenuError } = await supabaseClient
            .from("menu_data")
            .update([{
                name: edit_name,
                description: edit_description,
                price: edit_price,
            }])
            .eq('id', edit_id);

        if (addMenu) {
        } else if (addMenuError) {
        }

        const { data } = await supabaseClient.from('menu_data').select("*").eq('b_id', 1).order("id", { ascending: true });
        setMenus(data)

        // setMenus([...menus, {
        //     studio_id: 1,
        //     name: edit_name,
        //     description: edit_description,
        //     price: edit_price,
        //     composition: edit_composition,
        //     time: edit_time
        // }])

        closeEditModal();
    };
    async function deleteItem() {
        const { error } = await supabaseClient
            .from('menu_data')
            .delete()
            .eq('id', edit_id)

        const { data } = await supabaseClient.from('menu_data').select("*").eq('b_id', 1).order("id", { ascending: true });
        setMenus(data)

        closeEditModal();
    }

    function encodeFilename(filename) {
        return Buffer.from(filename).toString('base64');
    }
    return (
        <Manage>
            <div className="w-full p-4 md:ml-64">
                <div className="p-4 border-2 border-gray-200 border-dashed rounded-lg dark:border-gray-700">
                    <h2 className="mb-5 font-bold text-xl text-3xl mb-2 text-black">메뉴 관리</h2>
                    <div className="flex md:justify-start justify-center">
                        <button
                            onClick={() => openModal()}
                            type="button"
                            className="text-center py-2.5 px-5 ml-2 mt-2 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700"
                        >
                            메뉴 추가
                        </button>
                    </div>

                    {isLoading ?
                        <div className="flex flex-row mx-auto my-20 md:-my-20 h-screen justify-center md:items-center">
                            <div className="w-40 h-40 rounded-full animate-spin 
                        border-2 border-solid border-blue-500 border-t-transparent"></div>
                        </div>
                        :
                        <div>
                            {menus != null && menus.length > 0 ?
                                <div className='mt-5 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-2 md:gap-3'>
                                    {menus.map((menu) => (
                                        <button
                                            type="button" key={menu.name} onClick={(e) => openEditModal(menu)}>
                                            <div className="w-full my-1 bg-white border border-gray-300 rounded-lg shadow-xl flex" >
                                                {(menu.image != "" && menu.image) &&
                                                    <Image
                                                        src={menu.image}
                                                        width={150}
                                                        height={150}
                                                        alt={''}
                                                        style={{ objectFit: "cover" }}
                                                        className="w-1/3 min-w-[100px] aspect-square object-none rounded-t-lg rounded-l-lg">
                                                    </Image>
                                                }
                                                <div className="py-6 px-3 text-left">
                                                    <h2 className="font-bold text-lg mb-2 text-orange-700">{menu.name}</h2>
                                                    <p className="text-orange-700 px-1">
                                                        {menu.price.toLocaleString()} 원
                                                    </p>
                                                </div>
                                            </div>
                                        </button>

                                    ))}
                                </div>
                                :
                                <p className="mt-5 ml-5">등록된 메뉴가 없습니다.</p>}

                        </div>
                    }
                </div>


            </div>

            {showModal ?
                <div className="w-full h-screen bg-black/75 fixed top-0 z-40">
                    <div tabIndex={-1} aria-hidden="true" className="flex items-center justify-center pb-20 w-full p-4 overflow-x-hidden overflow-y-auto md:inset-0 h-[calc(100%-1rem)] md:h-full">
                        <div className="relative w-full h-auto max-w-2xl">
                            <div className="relative bg-white rounded-lg shadow dark:bg-gray-700">
                                <div className="flex items-start justify-between p-4 border-b rounded-t dark:border-gray-600">
                                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white">
                                        메뉴 추가
                                    </h3>

                                    <button type="button" onClick={() => closeModal()} className="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center dark:hover:bg-gray-600 dark:hover:text-white">
                                        <svg aria-hidden="true" className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd"></path></svg>
                                        <span className="sr-only">Close modal</span>
                                    </button>
                                </div>
                                <div className="p-6">
                                    <p className="block text-sm font-medium text-gray-900 dark:text-white" >메뉴 이미지</p>
                                    <input name="menu_image" onChange={(e) => { handleInputImageChange(e) }} type="file" accept="image/*" className="block mt-2 w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 dark:text-gray-400 focus:outline-none dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 file:bg-blue-200 file:text-blue-700 file:font-semibold file:border-none file:px-4 file:py-1 file:mr-6 file:rounded " />

                                    <p className="block mt-5 text-sm font-medium text-gray-900 dark:text-white" >메뉴 이름</p>
                                    <input type="text" onChange={handleInputChange} name="menu_name" className="mt-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="메뉴 이름" required />
                                    <p className="block mt-5 text-sm font-medium text-gray-900 dark:text-white" >가격</p>
                                    <input type="number" onChange={handleInputChange} name="menu_price" className="mt-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="가격" required />
                                    <p className="block mt-5 text-sm font-medium text-gray-900 dark:text-white" >메뉴 설명</p>
                                    <input type="text" onChange={handleInputChange} name="menu_description" className="mt-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="메뉴 설명" required />

                                </div>
                                <div className="flex justify-center md:justify-start items-center p-6 space-x-2 border-t border-gray-200 rounded-b dark:border-gray-600">
                                    <button type="submit" onClick={(e) => { handleSubmit(e) }} className="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">추가</button>
                                    <button type="button" onClick={() => closeModal()} className="text-gray-500 bg-white hover:bg-gray-100 focus:ring-4 focus:outline-none focus:ring-blue-300 rounded-lg border border-gray-200 text-sm font-medium px-5 py-2.5 hover:text-gray-900 focus:z-10 dark:bg-gray-700 dark:text-gray-300 dark:border-gray-500 dark:hover:text-white dark:hover:bg-gray-600 dark:focus:ring-gray-600">취소</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div> : null}

            {showEditModal ?
                <div className="w-full h-screen bg-black/75 fixed top-0 z-40">
                    <div tabIndex={-1} aria-hidden="true" className="flex items-center justify-center w-full p-4 overflow-x-hidden overflow-y-auto md:inset-0 h-[calc(100%-1rem)] md:h-full">
                        <div className="relative w-full h-auto max-w-2xl">
                            <div className="relative bg-white rounded-lg shadow dark:bg-gray-700">
                                <div className="flex items-start justify-between p-4 border-b rounded-t dark:border-gray-600">
                                    <h3 className="text-xl font-semibold text-gray-900 dark:text-white">
                                        메뉴 수정
                                    </h3>

                                    <button type="button" onClick={() => closeEditModal()} className="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm p-1.5 ml-auto inline-flex items-center dark:hover:bg-gray-600 dark:hover:text-white">
                                        <svg aria-hidden="true" className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd"></path></svg>
                                        <span className="sr-only">Close modal</span>
                                    </button>
                                </div>
                                <form onSubmit={(e) => { handleEditSubmit(e) }}>
                                    <div className="p-6">
                                        {photoToAddPreview()}
                                        <input name="menu_image" ref={photoInput} onChange={(e) => { handleInputImageChange(e) }} type="file" accept="image/*" className="block mt-2 w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 dark:text-gray-400 focus:outline-none dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 file:bg-blue-200 file:text-blue-700 file:font-semibold file:border-none file:px-4 file:py-1 file:mr-6 file:rounded " />

                                        {/* <p className="block text-sm font-medium text-gray-900 dark:text-white" >메뉴 이미지</p>
                                <input name="menu_image" onChange={(e) => {handleInputImageChange(e)}} type="file" accept="image/*" className="block mt-2 w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 dark:text-gray-400 focus:outline-none dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400" /> */}
                                        <p className="block mt-5 text-sm font-medium text-gray-900 dark:text-white" >상품 이름</p>
                                        <input type="text" onChange={handleEditInputChange} name="edit_name" defaultValue={edit_name} className="mt-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="상품 이름" required />
                                        <p className="block mt-5 text-sm font-medium text-gray-900 dark:text-white" >상품 안내</p>
                                        <input type="text" onChange={handleEditInputChange} name="edit_description" defaultValue={edit_description} className="mt-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="상품 안내" required />
                                        <p className="block mt-5 text-sm font-medium text-gray-900 dark:text-white" >가격</p>
                                        <input type="number" onWheel={numberInputOnWheelPreventChange} onChange={handleEditInputChange} name="edit_price" defaultValue={edit_price} className="mt-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="가격" required />
                                    </div>
                                    <div className="flex justify-center md:justify-start items-center p-6 space-x-2 border-t border-gray-200 rounded-b dark:border-gray-600">
                                        <button type="submit" className="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">수정</button>
                                        <button type="button" onClick={() => deleteItem()} className="text-white bg-red-700 hover:bg-red-800 focus:ring-4 focus:outline-none focus:ring-red-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-800">삭제</button>
                                        <button type="button" onClick={() => closeEditModal()} className="text-gray-500 bg-white hover:bg-gray-100 focus:ring-4 focus:outline-none focus:ring-blue-300 rounded-lg border border-gray-200 text-sm font-medium px-5 py-2.5 hover:text-gray-900 focus:z-10 dark:bg-gray-700 dark:text-gray-300 dark:border-gray-500 dark:hover:text-white dark:hover:bg-gray-600 dark:focus:ring-gray-600">취소</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div> : null}

        </Manage>
    );
}