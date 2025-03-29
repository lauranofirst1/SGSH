import { supabaseClient } from "@/lib/supabase";
import Image from "next/image";
import { useEffect, useState, useRef } from "react";

export default function ManageInfo() {
    const photoInput = useRef(null);

    const [isLoading, setIsLoading] = useState(true);
    const [image, setImage] = useState(null);
    const [isImageChanged, setIsImageChanged] = useState(false);
    const [business, setBusiness] = useState([]);
    const [updateBusiness, setUpdateBusiness] = useState({
        image: "",
        name: "",
        address: "",
        time: ""
    });
    const [photoToAddList, setPhotoToAddList] = useState([]);


    useEffect(() => {
        const fetchMenus = async () => {
            const { data } = await supabaseClient.from('business_data').select("*").eq('id', 1);
            setBusiness(data)
            setUpdateBusiness({
                image: data[0].image,
                name: data[0].name,
                address: data[0].address,
                time: data[0].time
            })
            setPhotoToAddList(data[0].image);
            setIsLoading(false)
        }
        fetchMenus()
    }, []);

    const updateInfo = async (e) => {
        e.preventDefault();


        if (image != null) {
            const { data: uploadImage, error: uploadImageError } = await supabaseClient.storage.from("images").upload("menu_images/" + String(1) + "/main/" + encodeFilename(image?.name), image);
            if (uploadImage) {
                // console.log("uploadImage");
            } else if (uploadImageError) {
                // console.log(uploadImageError);
            }
        }

        business[0].image = updateBusiness.image

        const { data } = await supabaseClient
            .from('business_data')
            .update({
                image: updateBusiness.image,
                name: updateBusiness.name,
                address: updateBusiness.address,
                time: updateBusiness.time,
            })
            .eq("id", 1);

        if (data) {
        }

        if (isImageChanged) {
            (async () => {
                setIsLoading(true)
                business[0].image = updateBusiness.image;
                await sleep(3);
                setIsLoading(false)
                setIsImageChanged(false)
            })();
        } else {
            (async () => {
                setIsLoading(true)
                await sleep(1);
                setIsLoading(false)
            })();
        }

    }


    const handleInputImageChange = (e) => {
        if (e.target.files != null) {
            setImage(e.target.files[0]);
            updateBusiness.image = "https://cytktlrbanxiswqurqth.supabase.co/storage/v1/object/public/images/menu_images/" + String(1) + "/main/" + encodeFilename(e.target.files[0].name);
            business[0].image = updateBusiness.image;
            setIsImageChanged(true);

            setPhotoToAddList(URL.createObjectURL(e.target.files[0]));
        }
    };

    const handleInputChange = (e) => {
        const value = e.target.value;
        setUpdateBusiness({ ...updateBusiness, [e.target.name]: value });
    };

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

            // <img onClick={(e) => deletePhoto(image)} className="aspect-[3/2] w-[9rem] md:w-[15rem] h-[6rem] md:h-[10rem] border-2 rounded-xl" src={photoToAddList} />
        )

    };

    function encodeFilename(filename) {
        return Buffer.from(filename).toString('base64');
    }
    function sleep(sec) {
        return new Promise(resolve => setTimeout(resolve, sec * 1000));
    }

    return (
        <>
            <div className="w-full p-4 md:ml-64">
                <div className="p-4 border-2 border-gray-200 border-dashed rounded-lg dark:border-gray-700">
                    <h2 className="mb-5 font-bold text-xl text-3xl mb-2 text-black">가게 정보</h2>
                    {isLoading ?
                        <div className="flex flex-row mx-auto my-20 md:-my-20 h-screen justify-center md:items-center">
                            <div className="w-40 h-40 rounded-full animate-spin 
                            border-2 border-solid border-blue-500 border-t-transparent"></div>
                        </div>
                        :
                        <div>
                            {business != null && business.length == 1 ?
                                <div key={business.id}>
                                    <p className="text-sm font-medium text-gray-900" >대표 이미지</p>
                                    {/* {business[0].image != "" &&
                                        <Image
                                            className="h-60"
                                            src={business[0].image}
                                            alt={''}
                                            width={500}
                                            height={500}
                                            style={{ objectFit: "cover" }}>
                                        </Image>
                                    } */}
                                    {photoToAddPreview()}


                                    <input name="menu_image" ref={photoInput} onChange={(e) => { handleInputImageChange(e) }} type="file" accept="image/*" className="block mt-2 w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 dark:text-gray-400 focus:outline-none dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400" />

                                    <p className="mt-5 text-sm font-medium text-gray-900" >가게 이름</p>
                                    <input type="text" name="name" onChange={handleInputChange} defaultValue={updateBusiness.name} placeholder="카페 이름" className="mt-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" required />

                                    <p className="mt-5 text-sm font-medium text-gray-900" >가게 주소</p>
                                    <input type="text" name="address" onChange={handleInputChange} defaultValue={updateBusiness.address} placeholder="카페 이름" className="mt-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" required />

                                    <p className="mt-5 text-sm font-medium text-gray-900" >영업 시간</p>
                                    <input type="text" name="time" onChange={handleInputChange} defaultValue={updateBusiness.time} placeholder="영업 시간" className="mt-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" required />

                                    <div className="flex justify-center md:justify-start items-center">
                                        <button type="button"
                                            onClick={updateInfo}
                                            className="mt-5 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-7 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">저장</button>
                                    </div>
                                </div>

                                :
                                <p>로딩 에러</p>
                            }
                        </div>
                    }
                </div>
            </div>
        </>
    )
}