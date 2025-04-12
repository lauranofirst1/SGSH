'use client'

import Manage from "../page";
import ManageNavBar from "@/components/feature/manage_navbar";

import { useState, useEffect, useRef } from 'react';
import Script from 'next/script';
import Head from 'next/head';
import { Noto_Sans_KR, Nanum_Gothic, Jua } from 'next/font/google';

// 폰트 설정
const notoSansKr = Noto_Sans_KR({
    subsets: ['latin'],
    weight: ['400', '700'],
    display: 'swap',
    variable: '--font-noto-sans-kr',
});

const nanumGothic = Nanum_Gothic({
    subsets: ['latin'],
    weight: ['400', '700'],
    display: 'swap',
    variable: '--font-nanum-gothic',
});

const JUA = Jua({
    subsets: ['latin'],
    weight: ['400'],
    display: 'swap',
    variable: '--font-nanum-gothic',
});


export default function ManagePost() {
    // 이미지 관련 상태
    const [image, setImage] = useState({
        src: "https://placehold.co/800x800/000000/000000/png",
        name: "",
        isUploaded: false
    });

    // 첫번째 텍스트 관련 상태
    const [primaryText, setPrimaryText] = useState({
        content: "텍스트를 입력하세요",
        position: { x: 50, y: 50 },
        style: {
            fontSize: 35,
            color: "#ffffff",
            isEntered: false
        }
    });

    // 두번째 텍스트 관련 상태
    const [secondaryText, setSecondaryText] = useState({
        content: "두번째 텍스트를 입력하세요",
        position: { x: 70, y: 90 },
        style: {
            fontSize: 20,
            color: "#ffffff",
            isEntered: false
        }
    });

    // 공통 텍스트 스타일 상태
    const [textStyle, setTextStyle] = useState({
        fontWeight: "bold",
        textAlign: "center",
        fontFamily: "Arial, sans-serif", // 기본값으로 Arial
        outline: {
            enabled: true,
            color: "#000000",
            width: 1
        }
    });

    // 폰트 관련 상태 (제거함)
    // const [fonts, setFonts] = useState([
    //   { name: 'Arial', value: 'Arial, sans-serif' },
    //   { name: 'Verdana', value: 'Verdana, sans-serif' },
    //   { name: '맑은 고딕', value: "'Malgun Gothic', sans-serif" }
    // ]);

    const [fontSizeRatio, setFontSizeRatio] = useState(secondaryText.style.fontSize / primaryText.style.fontSize);

    // 스크롤 관련 상태
    const previewPanelRef = useRef(null);
    const [previewState, setPreviewState] = useState({
        startPosition: 0,
        width: 0,
        isFixed: false,
        lastScrollPosition: 0
    });

    const thumbnailPreviewRef = useRef(null);


    const handleImageUpload = (e) => {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function (e) {
                const img = new Image();
                img.onload = function () {
                    // 이미지 중앙 크롭쓰
                    const canvas = document.createElement('canvas');
                    const ctx = canvas.getContext('2d');

                    const size = Math.min(img.width, img.height);
                    const startX = (img.width - size) / 2;
                    const startY = (img.height - size) / 2;

                    canvas.width = size;
                    canvas.height = size;
                    ctx.drawImage(img, startX, startY, size, size, 0, 0, size, size);

                    // 크롭 이미지로 업데이트
                    setImage({
                        src: canvas.toDataURL('image/png'),
                        name: file.name,
                        isUploaded: true
                    });
                };
                img.src = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    };


    const handlePrimaryTextInput = (e) => {
        const value = e.target.value.trim();
        setPrimaryText(prev => ({
            ...prev,
            content: value || "텍스트를 입력하세요",
            style: {
                ...prev.style,
                isEntered: value.length > 0
            }
        }));
    };

    // 다운로드 버튼 상태 확인
    const isDownloadEnabled = () => {
        return image.isUploaded && primaryText.style.isEntered && secondaryText.style.isEntered;
    };

    // 두번째 텍스트 입력 처리
    const handleSecondaryTextInput = (e) => {
        const value = e.target.value.trim();
        setSecondaryText(prev => ({
            ...prev,
            content: value || "두번째 텍스트를 입력하세요",
            style: {
                ...prev.style,
                isEntered: value.length > 0
            }
        }));
    };

    // 위치 조정 처리
    // 위치 상단, 중단, 하단 값 지정
    const fixedPositions = { 'top': 20, 'middle': 50, 'bottom': 75 };
    const handlePositionChange = (position, isSecondary = false) => {
        // const fixedPositions = {'top': 20, 'middle': 50, 'bottom': 70};
        setPrimaryText(prev => ({
            ...prev,
            position: {
                x: 50,
                y: fixedPositions[position]
            }
        }));
    };



    // 폰트 선택 핸들러
    // const handleFontChange = (fontValue) => {
    //   setTextStyle(prev => ({
    //     ...prev,
    //     fontFamily: fontValue
    //   }));
    // };
    //
    // // JSX 부분에 폰트 선택 드롭다운 추가
    // <select
    //   value={textStyle.fontFamily}
    //   onChange={(e) => handleFontChange(e.target.value)}
    // >
    //   {fonts.map((font, index) => (
    //     <option key={index} value={font.value}>
    //       {font.name}
    //     </option>
    //   ))}
    // </select>

    // 폰트 로딩 확인용 하..
    // useEffect(() => {
    //   if (typeof window !== 'undefined') {
    //     document.fonts.ready.then(() => {
    //       console.log('모든 폰트 로드 완료쓰');
    //       fonts.forEach(font => {
    //         const fontName = font.value.split("'")[1];
    //         if (fontName && !fontName.includes(',')) {
    //           const isLoaded = document.fonts.check(`1em ${fontName}`);
    //           console.log(`${fontName}: ${isLoaded ? '로드됨' : '로드되지 않음'}`);
    //         }
    //       });
    //     });
    //   }
    // }, [fonts]);


    // 폰트 크기 조정
    const handleFontSizeChange = (value) => {
        // 빈 문자열이면 기본값 사용
        if (value === '') {
            const defaultFontSize = 35;
            setPrimaryText(prev => ({
                ...prev,
                style: {
                    ...prev.style,
                    fontSize: defaultFontSize
                }
            }));
            setSecondaryText(prev => ({
                ...prev,
                style: {
                    ...prev.style,
                    fontSize: defaultFontSize * fontSizeRatio
                }
            }));
            return;
        }

        // parseInt 결과가 NaN인지 확인
        const numValue = parseInt(value, 10);
        if (isNaN(numValue)) {
            return; // NaN이면 상태 업데이트 하지 않음
        }

        setPrimaryText(prev => ({
            ...prev,
            style: {
                ...prev.style,
                fontSize: numValue
            }
        }));
        setSecondaryText(prev => ({
            ...prev,
            style: {
                ...prev.style,
                fontSize: numValue * fontSizeRatio
            }
        }));
    };


    // 폰트 색상 변경
    const handleFontColorChange = (color, isSecondary = false) => {
        if (isSecondary) {
            setSecondaryText(prev => ({
                ...prev,
                style: {
                    ...prev.style,
                    color
                }
            }));
        } else {
            setPrimaryText(prev => ({
                ...prev,
                style: {
                    ...prev.style,
                    color
                }
            }));
        }
    };

    // 공통 스타일 변경
    const handleCommonStyleChange = (property, value) => {
        setTextStyle(prev => ({
            ...prev,
            [property]: value
        }));
    };

    // 테두리 설정 변경
    const handleOutlineChange = (enabled) => {
        setTextStyle(prev => ({
            ...prev,
            outline: {
                ...prev.outline,
                enabled
            }
        }));
    };

    // 테두리 속성 변경
    const handleOutlinePropertyChange = (property, value) => {
        setTextStyle(prev => ({
            ...prev,
            outline: {
                ...prev.outline,
                [property]: value
            }
        }));
    };

    // 그림자 스타일 생성 함수
    const getTextShadowStyle = () => {
        // if (textStyle.outline.enabled) {  // enabled true 긴한데 그냥 제거

        const width = textStyle.outline.width;
        const color = textStyle.outline.color;

        // 16방향 테두리
        return `${width}px 0 ${color},
        ${width * 0.7071}px ${width * 0.7071}px ${color},
        0 ${width}px ${color},
        -${width * 0.7071}px ${width * 0.7071}px ${color},
        -${width}px 0 ${color},
        -${width * 0.7071}px -${width * 0.7071}px ${color},
        0 -${width}px ${color},
        ${width * 0.7071}px -${width * 0.7071}px ${color},
        ${width * 0.3827}px ${width * 0.9239}px ${color},
        -${width * 0.3827}px ${width * 0.9239}px ${color},
        -${width * 0.9239}px ${width * 0.3827}px ${color},
        -${width * 0.9239}px -${width * 0.3827}px ${color},
        -${width * 0.3827}px -${width * 0.9239}px ${color},
        ${width * 0.3827}px -${width * 0.9239}px ${color},
        ${width * 0.9239}px -${width * 0.3827}px ${color},
        ${width * 0.9239}px ${width * 0.3827}px ${color}`;

        // }
        // return 'none';
    };

    // 텍스트 스타일 계산
    const getTextStyle = (isSecondary = false) => {
        if (isSecondary) {
            return {
                position: 'absolute',
                left: '50%',
                top: `calc(${primaryText.position.y}% + ${primaryText.style.fontSize * 1.2}px)`, // 첫 번째 텍스트 아래에 위치하도록 조정
                transform: 'translate(-50%, -50%)',
                fontSize: `${secondaryText.style.fontSize}px`,
                color: secondaryText.style.color,
                fontWeight: textStyle.fontWeight,
                textAlign: 'center',
                fontFamily: textStyle.fontFamily,
                width: '100%',
                lineHeight: '1.5',
                textShadow: getTextShadowStyle(),
                whiteSpace: 'pre-wrap',
                pointerEvents: 'none'
            };
        } else {
            // 첫 번째 텍스트 스타일은 그대로 유지
            return {
                position: 'absolute',
                left: '50%',
                top: `${primaryText.position.y}%`,
                transform: 'translate(-50%, -50%)',
                fontSize: `${primaryText.style.fontSize}px`,
                color: primaryText.style.color,
                fontWeight: textStyle.fontWeight,
                textAlign: 'center',
                fontFamily: textStyle.fontFamily,
                width: '100%',
                lineHeight: '1.5',
                textShadow: getTextShadowStyle(),
                whiteSpace: 'pre-wrap',
                pointerEvents: 'none'
            };
        }
    };

    // 스크롤 이벤트
    const handleScroll = () => {
        if (typeof window === 'undefined' || !previewPanelRef.current) return;

        // 모바일 화면에서는 적용하지 않음
        if (window.innerWidth <= 768) {
            resetPreviewPanel();
            return;
        }

        const currentScroll = window.scrollY;
        const windowHeight = window.innerHeight;
        const previewHeight = previewPanelRef.current.offsetHeight;
        const parentBottom = previewPanelRef.current.parentElement.offsetTop +
            previewPanelRef.current.parentElement.offsetHeight;

        // 실시간 현재 패널 너비 업데이트
        const currentWidth = previewPanelRef.current.offsetWidth;

        // 미리보기 패널이 너무 크면 따라오기를 적용하지 않음
        if (previewHeight > windowHeight) return;

        // 스크롤 위치에 따라 미리보기 패널 위치 조정
        if (currentScroll > previewState.startPosition) {
            if (currentScroll + previewHeight + 20 < parentBottom) {
                setPreviewState(prev => ({
                    ...prev,
                    isFixed: true,
                    width: currentWidth // 현재 너비로 업데이트
                }));
            } else {
                setPreviewState(prev => ({
                    ...prev,
                    isFixed: false
                }));
            }
        } else {
            resetPreviewPanel();
        }

        // 현재 스크롤 위치를 로컬 스토리지에 저장
        localStorage.setItem('scrollPosition', currentScroll.toString());
    };

    const handleResize = () => {
        if (!previewPanelRef.current) return;

        // 현재 스크롤 위치, 상태
        // const currentScrollY = window.scrollY;
        const wasFixed = previewState.isFixed;

        // requestAnimationFrame을 사용하여 렌더링 사이클에 맞춰 실행
        requestAnimationFrame(() => {
            if (!previewPanelRef.current) return;

            setPreviewState(prev => ({
                ...prev,
                width: previewPanelRef.current.offsetWidth,
                startPosition: previewPanelRef.current.parentElement.offsetTop,
                isFixed: wasFixed
            }));

            handleScroll();
        });

        if (window.innerWidth <= 768) {
            resetPreviewPanel();
        }
    };

    const resetPreviewPanel = () => {
        setPreviewState(prev => ({
            ...prev,
            isFixed: false
        }));
    };

    // 스크롤 관련
    useEffect(() => {
        if (typeof window === 'undefined') return;

        // 초기 위치 및 너비 설정
        if (previewPanelRef.current) {
            const savedScrollPosition = localStorage.getItem('scrollPosition');
            const initialScrollPosition = savedScrollPosition ? parseInt(savedScrollPosition, 10) : 0;

            setPreviewState({
                startPosition: previewPanelRef.current.getBoundingClientRect().top + window.scrollY,
                width: previewPanelRef.current.clientWidth,
                isFixed: initialScrollPosition > previewPanelRef.current.getBoundingClientRect().top,
                lastScrollPosition: initialScrollPosition
            });

            // 저장된 스크롤 위치로 이동
            window.scrollTo(0, initialScrollPosition);
        }

        window.addEventListener('scroll', handleScroll);
        window.addEventListener('resize', handleResize);

        return () => {
            window.removeEventListener('scroll', handleScroll);
            window.removeEventListener('resize', handleResize);
        };
    }, [previewState.isFixed, previewState.width]); // previewState.isFixed 변경시 재실행


    // 다운로드 기능
    const downloadThumbnail = () => {
        if (typeof window !== 'undefined' && window.html2canvas) {
            window.html2canvas(thumbnailPreviewRef.current, {
                allowTaint: true,
                useCORS: true,
                scale: 4
            }).then(canvas => {
                const link = document.createElement('a');
                link.download = 'thumbnail.png';
                link.href = canvas.toDataURL('image/png');
                link.click();
            });
        }
    };
    return (
        <Manage>
            <Head>
                <title>썸네일 생성기</title>
                <link rel="stylesheet" href="/fonts/fonts.css" />
            </Head>

            <Script src="https://html2canvas.hertzen.com/dist/html2canvas.min.js" strategy="beforeInteractive" />

            <div className="w-full md:ml-64">
                <ManageNavBar />
                <div className="p-4">
                    <div className="p-4 border-2 border-gray-200 border-dashed rounded-lg dark:border-gray-700">
                        <h2>홍보글 생성 페이지</h2>

                        <div className="container mx-auto px-4 py-8 max-w-6xl">
                            <h1 className="text-4xl font-bold text-center mb-8 text-indigo-700"></h1>

                            <div className="flex flex-col md:flex-row bg-white rounded-xl shadow-lg overflow-hidden">
                                {/* 왼쪽 패널 : 설정들 */}
                                <div className="w-full md:w-1/2 p-6 md:border-r border-gray-200 overflow-y-auto">
                                    <h2 className="text-2xl font-semibold mb-6 text-gray-800">설정</h2>

                                    {/* 이미지 업로드 */}
                                    <div className="mb-8">
                                        <label className="block text-gray-700 font-medium mb-2">이미지 업로드</label>
                                        <div className="flex items-center justify-center w-full">
                                            <label className="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed border-indigo-300 bg-indigo-50 hover:bg-indigo-100 hover:border-indigo-400 rounded-lg cursor-pointer transition duration-300">
                                                <div className="flex flex-col items-center justify-center pt-5 pb-6">
                                                    <svg className="w-10 h-10 text-indigo-500 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                                                    </svg>
                                                    <p className="text-sm text-indigo-600">이미지를 업로드하세요</p>
                                                </div>
                                                <input id="image-upload" type="file" className="hidden" accept="image/*" onChange={handleImageUpload} />
                                            </label>
                                        </div>
                                        <p className="mt-2 text-sm text-gray-500">{image.name}</p>
                                    </div>

                                    <hr className="mb-8" />

                                    {/* 텍스트 입력 */}
                                    <div className="mb-4">
                                        <textarea
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition"
                                            rows="3"
                                            placeholder="텍스트를 입력하세요"
                                            onChange={handlePrimaryTextInput}
                                        ></textarea>
                                    </div>

                                    {/* 두번째 텍스트 입력 */}
                                    <div className="mb-4">
                                        <textarea
                                            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition"
                                            rows="3"
                                            placeholder="두번째 텍스트를 입력하세요"
                                            onChange={handleSecondaryTextInput}
                                        ></textarea>
                                    </div>

                                    {/* 텍스트 위치 조정 */}
                                    <div className="mb-8">

                                        <div className="mb-4">
                                            <label className="block text-gray-700 text-sm mb-2">텍스트 위치</label>
                                            <div className="flex justify-between gap-2">
                                                <button
                                                    className={`flex-1 py-3 px-4 rounded-lg transition-all duration-200 flex flex-col items-center ${primaryText.position.y === fixedPositions['top'] ? 'bg-indigo-500 text-white shadow-md' : 'bg-gray-100 hover:bg-gray-200 text-gray-700'}`}
                                                    onClick={() => handlePositionChange('top')}
                                                >
                                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mb-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                        <rect x="4" y="4" width="16" height="16" rx="2" />
                                                        <line x1="8" y1="8" x2="16" y2="8" />
                                                    </svg>
                                                    <span className="text-xs">상단</span>
                                                </button>

                                                <button
                                                    className={`flex-1 py-3 px-4 rounded-lg transition-all duration-200 flex flex-col items-center ${primaryText.position.y === fixedPositions['middle'] ? 'bg-indigo-500 text-white shadow-md' : 'bg-gray-100 hover:bg-gray-200 text-gray-700'}`}
                                                    onClick={() => handlePositionChange('middle')}
                                                >
                                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mb-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                        <rect x="4" y="4" width="16" height="16" rx="2" />
                                                        <line x1="8" y1="12" x2="16" y2="12" />
                                                    </svg>
                                                    <span className="text-xs">중앙</span>
                                                </button>

                                                <button
                                                    className={`flex-1 py-3 px-4 rounded-lg transition-all duration-200 flex flex-col items-center ${primaryText.position.y === fixedPositions['bottom'] ? 'bg-indigo-500 text-white shadow-md' : 'bg-gray-100 hover:bg-gray-200 text-gray-700'}`}
                                                    onClick={() => handlePositionChange('bottom')}
                                                >
                                                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mb-1" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                        <rect x="4" y="4" width="16" height="16" rx="2" />
                                                        <line x1="8" y1="16" x2="16" y2="16" />
                                                    </svg>
                                                    <span className="text-xs">하단</span>
                                                </button>
                                            </div>
                                        </div>

                                        <div className="mb-4">
                                            <label className="block text-gray-700 text-sm mb-1" htmlFor="font-size">폰트 크기</label>
                                            <div className="flex items-center">
                                                <input
                                                    type="range"
                                                    className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
                                                    min="8"
                                                    max="72"
                                                    value={primaryText.style.fontSize}
                                                    onChange={(e) => handleFontSizeChange(e.target.value)}
                                                />
                                                <input
                                                    type="number"
                                                    className="ml-4 w-16 px-2 py-1 border border-gray-300 rounded text-center"
                                                    min="8"
                                                    max="72"
                                                    value={primaryText.style.fontSize}
                                                    onChange={(e) => handleFontSizeChange(e.target.value)}
                                                />
                                            </div>
                                        </div>

                                        {/*</div>*/}

                                        <div className="grid grid-cols-2 gap-4 mb-4">
                                            <div>
                                                <label className="block text-gray-700 text-sm mb-1" htmlFor="font-color">폰트 색상 1</label>
                                                <input
                                                    type="color"
                                                    className="h-10 w-full border border-gray-300 rounded cursor-pointer"
                                                    value={primaryText.style.color}
                                                    onChange={(e) => handleFontColorChange(e.target.value)}
                                                />
                                            </div>

                                            <div>
                                                <label className="block text-gray-700 text-sm mb-1" htmlFor="font-color-2">폰트 색상 2</label>
                                                <input
                                                    type="color"
                                                    className="h-10 w-full border border-gray-300 rounded cursor-pointer"
                                                    value={secondaryText.style.color}
                                                    onChange={(e) => handleFontColorChange(e.target.value, true)}
                                                />
                                            </div>
                                        </div>
                                    </div>

                                    <hr className="mb-8" />

                                    {/* 텍스트 스타일 */}
                                    <div className="mb-8">
                                        {/* 폰트 선택 */}
                                        <div className="mb-8">
                                            <h3 className="font-medium mb-3 text-gray-800">폰트 선택</h3>
                                            <div className="mb-4">
                                                <label className="block text-gray-700 text-sm mb-1" htmlFor="font-family">폰트</label>
                                                <select
                                                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                                                    value={textStyle.fontFamily}
                                                    onChange={(e) => handleCommonStyleChange('fontFamily', e.target.value)}
                                                >
                                                    <option value="Arial, sans-serif">Arial</option>
                                                    <option value={`${notoSansKr.style.fontFamily}`}>Noto Sans KR</option>
                                                    <option value={`${nanumGothic.style.fontFamily}`}>Nanum Gothic</option>
                                                    <option value={`${JUA.style.fontFamily}`}>JUA</option>
                                                </select>
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-2 gap-4 mb-4">
                                            <div>
                                                <label className="block text-gray-700 text-sm mb-1" htmlFor="font-weight">폰트 굵기</label>
                                                <select
                                                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                                                    value={textStyle.fontWeight}
                                                    onChange={(e) => handleCommonStyleChange('fontWeight', e.target.value)}
                                                >
                                                    <option value="normal">보통</option>
                                                    <option value="bold">굵게</option>
                                                    <option value="bolder">더 굵게</option>
                                                    <option value="lighter">얇게</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>

                                    {/* 테두리 옵션 */}
                                    <div className="mb-4">
                                        <h3 className="font-medium mb-3 text-gray-800">텍스트 테두리 설정</h3>
                                        <div className="mt-2">
                                            <label className="block text-gray-700 text-sm mb-1" htmlFor="outline-color">테두리 색상</label>
                                            <input
                                                type="color"
                                                className="h-10 w-full border border-gray-300 rounded cursor-pointer"
                                                value={textStyle.outline.color}
                                                onChange={(e) => handleOutlinePropertyChange('color', e.target.value)}
                                            />
                                            <label className="block text-gray-700 text-sm mb-1 mt-2" htmlFor="outline-width">테두리 두께</label>
                                            <input
                                                type="range"
                                                className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
                                                min="1"
                                                max="5"
                                                value={textStyle.outline.width}
                                                onChange={(e) => handleOutlinePropertyChange('width', parseInt(e.target.value))}
                                            />
                                            <input
                                                type="number"
                                                className="ml-4 w-16 px-2 py-1 border border-gray-300 rounded text-center"
                                                min="1"
                                                max="5"
                                                value={textStyle.outline.width}
                                                onChange={(e) => handleOutlinePropertyChange('width', parseInt(e.target.value))}
                                            />
                                        </div>
                                    </div>


                                    {/* 다운로드 버튼 */}
                                    <div className="mt-8">
                                        <button
                                            className={`w-full font-bold py-3 px-4 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 transition duration-300 ${isDownloadEnabled() ? 'bg-indigo-600 hover:bg-indigo-700 text-white' : 'bg-gray-400 text-white'}`}
                                            disabled={!isDownloadEnabled()}
                                            onClick={downloadThumbnail}
                                        >
                                            다운로드
                                        </button>
                                    </div>
                                </div>

                                {/* 오른쪽 패널: 미리보기 */}
                                <div className="w-full md:w-1/2 p-6 bg-gray-50">
                                    <div
                                        ref={previewPanelRef}
                                        style={{
                                            position: previewState.isFixed ? 'fixed' : 'static',
                                            top: previewState.isFixed ? '20px' : 'auto',
                                            width: previewState.isFixed ? `${previewState.width}px` : 'auto'
                                        }}
                                        className="sticky top-5 max-h-[90vh] md:static md:max-h-full"
                                    >
                                        <h2 className="text-2xl font-semibold mb-6 text-gray-800">미리보기</h2>
                                        <div className="bg-gray-800 rounded-xl p-2 shadow-inner flex items-center justify-center">
                                            <div className="relative w-full aspect-square max-w-md mx-auto overflow-hidden rounded-lg shadow-lg">
                                                <div ref={thumbnailPreviewRef} className="relative overflow-hidden w-full h-full">
                                                    <img
                                                        src={image.src}
                                                        alt="썸네일 이미지"
                                                        className="absolute top-0 left-0 w-full h-full object-cover"
                                                    />
                                                    <div style={getTextStyle(false)}>{primaryText.content}</div>
                                                    <div style={getTextStyle(true)}>{secondaryText.content}</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>



        </Manage >
    );
}