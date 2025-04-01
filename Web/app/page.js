import Image from "next/image";

export default function Home() {
  return (

    <div className="flex flex-col">

      <div className="flex flex-col justify-center items-center bg-pink-50 py-20 md:py-30 px-4 bg-linear-to-b from-purple-200 to-pink-100">
        <p className="mt-10 text-3xl font-black">서비스 설명글</p>
        <p className="mt-6 text-4xl font-bold">서비스 이름</p>
        <button className="mt-10 px-10 py-3 bg-purple-600 rounded-full text-white text-lg font-extrabold">지금 신청하기</button>
        <Image className="my-10" width={600} height={500} src={"https://picsum.photos/1200/1000"} alt={"logo"} />
      </div>

      <div className="flex flex-col justify-center items-center py-10 px-4 text-center bg-white">
        <p className="mt-10 font-bold text-2xl/11">@@@ 서비스는</p>
        <p className="font-bold text-2xl/11">점주님과 고객님 모두 설레는 <br className="block md:hidden" />시간을 만들어 가겠습니다.</p>
        <p className="mt-4 md:mt-0 font-bold text-2xl/11">이제껏 경험 못 했던 예약 서비스로 <br className="block md:hidden" />우리의 일상은 새로워집니다.</p>

        <Image className="my-10" width={400} height={400} src={"https://picsum.photos/1000"} alt={"test"} />
      </div>

      <div className="flex flex-col justify-center items-center py-10 px-4 text-center bg-white">
        <p className="font-bold text-2xl/11">@@@ 서비스는</p>
        <p className="font-bold text-2xl/11">가장 유연한 예약관리를</p>
        <p className="font-bold text-2xl/11">제공합니다.</p>

        <Image className="my-10" width={400} height={600} src={"https://picsum.photos/800/1200"} alt={"스크린샷"} />
      </div>

      <div className="flex flex-col justify-center items-center py-10 px-4 text-center bg-white">
        <div className="mt-4">
          <p className="text-3xl font-black">인스타 하세요?</p>
          <p className="mt-4 text-gray-600 md:text-lg">인스타 프로필에 예약 페이지로</p>
          <p className="text-gray-600 md:text-lg"> 바로 연결할 수 있는 URL을 제공해 드려요.</p>
          <Image className="my-10" width={300} height={300} src={"https://picsum.photos/500"} alt={"스크린샷"} />
        </div>

        <div className="mt-4">
          <p className="text-3xl font-black">인스타 하세요?</p>
          <p className="mt-4 text-gray-600 md:text-lg">인스타 프로필에 예약 페이지로</p>
          <p className="text-gray-600 md:text-lg"> 바로 연결할 수 있는 URL을 제공해 드려요.</p>
          <Image className="my-10" width={300} height={300} src={"https://picsum.photos/550"} alt={"스크린샷"} />
        </div>

        <div className="mt-4">
          <p className="text-3xl font-black">인스타 하세요?</p>
          <p className="mt-4 text-gray-600 md:text-lg">인스타 프로필에 예약 페이지로</p>
          <p className="text-gray-600 md:text-lg"> 바로 연결할 수 있는 URL을 제공해 드려요.</p>
          <Image className="my-10" width={300} height={300} src={"https://picsum.photos/600"} alt={"스크린샷"} />
        </div>
      </div>

      <div className="flex flex-col mt-8 py-10 pl-14 text-start bg-slate-50">
        <p className="font-bold leading-7">서비스명</p>
        <p className="leading-7">위치</p>
        <p className="leading-7">사업자등록번호</p>
        <p className="leading-7">통신판매업 신고번호</p>
        <p className="leading-7">제휴문의</p>

      </div>

    </div>
  );
}
