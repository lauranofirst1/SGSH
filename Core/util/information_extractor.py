# -*- coding: utf-8 -*-

import os
from dotenv import load_dotenv
from langchain.chat_models import ChatOpenAI
from langchain.prompts import ChatPromptTemplate, PromptTemplate

load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

def extractor_information(articles):
    chat = ChatOpenAI(
        model="gpt-4o-mini",
        max_tokens=1500,
        temperature=0.1,
    )

    # 시스템 메시지 템플릿
    system_message = """
    당신은 블로그와 SNS 게시물에서 가게 정보를 추출하는 전문가입니다. 주어진 텍스트를 분석하여 가게에 대한 객관적인 정보와 주관적인 평가를 체계적으로 요약해주세요.
    정보가 명확하지 않은 경우 '정보 없음'으로, 확실하지 않은 정보는 '추정'이라고 표시해주세요.
    """

    # 인간 메시지 템플릿
    human_message = """
    당신은 블로그와 SNS 게시물에서 가게 정보를 추출하는 전문가입니다. 주어진 텍스트를 분석하여 다음 정보를 다음 형태로 체계적으로 요약해주세요:
    
    글 1 정보:
    1. 기본 정보
       - 가게 이름
       - 위치/주소
       - 영업 시간
       - 연락처
       - 가격대
       - 메뉴/상품 종류
    
    2. 시설 및 분위기
       - 인테리어/외관 특징
       - 좌석 배치/수용 인원
       - 분위기 (조용함/시끄러움, 격식/캐주얼 등)
       - 특별 시설 (주차장, 와이파이, 콘센트 등)
    
    3. 리뷰 요약
       - 전반적인 평가 (긍정/부정/중립)
       - 가장 호평받는 메뉴/상품/서비스
       - 단점이나 개선점
       - 작성자의 방문 경험 요약
       - 방문 당시 특이사항 (붐비는 정도, 대기 시간 등)
    
    4. 추천 정보
       - 추천 메뉴/상품
       - 방문 팁 (방문 시간, 예약 필요 여부 등)
       - 누구에게 추천하는지 (가족, 연인, 혼자 등)
    
    텍스트에서 명확하게 언급되지 않은 정보는 '정보 없음'으로 표시하고, 확실하지 않은 정보는 '추정'이라고 표시해주세요.
    가능한 한 객관적으로 정보를 요약하되, 작성자의 주관적인 의견과 평가도 포함해주세요.
    
    다음 블로그/SNS 게시물을 분석해주세요:
    
    {article_contents}
    """

    # 각 글에 대한 내용 생성
    article_contents = ""
    for i, article in enumerate(articles, 1):
        article_contents += f"글 {i}:\n{article}\n\n"

    messages = ChatPromptTemplate.from_messages([
        ("system", system_message),
        ("human", human_message)
    ])

    information_chain = messages | chat

    print("정보 추출 중...")

    information_final_chain = information_chain.invoke({
        "article_contents": article_contents,
    })

    print("정보 추출 완료!")

    return information_final_chain


# article1 = """
# [ 분위기 좋은 한림대맛집 춘천파스타 진스키친 다녀왔습니다,,☆  50m© NAVER Corp.더보기 /OpenStreetMap지도 데이터x© NAVER Corp. /OpenStreetMap지도 컨트롤러 범례부동산거리읍,면,동시,군,구시,도국가진스키친서울특별시 마포구 대흥로 112-2 한림대맛집 춘천파스타 진스키친은 한림대 바로 앞에 위치해 있는데요그래서인지 대학생들이 많이 오는 것 같더라고요 춘천파스타 진스키친은 한림대학교 학생에게는 10%할인도 해준다고 해요좀이따 보면 아시겠지만 가격대가 굉장히 합리적인데 거기에 더불어 10%할인까지 해준다니..한림대 학생분들께 완전 희소식입니다요아마 한림대생들 분들에게는 이미 알려진 맛집이 아닐까 싶었네요 한림대맛집 춘천파스타 진스키친은 이렇게 골목으로 들어가야 건물이 나오는데요앞에 입간판이 있어서 찾기 어렵지 않았어요 보시다시피 한림대맛집 춘천파스타 진스키친은 한옥을 개조한 곳이라 한옥 느낌 충만한 곳입니다 마당엔 꽃들과 자갈이 있어 고즈넉하고 편안한 느낌을 주더라고요한옥으로 된 매장 좋아하는 사람 나야 나,,☆ 나이는 못 속이나 봅니다(??) 바깥에는 테라스 자리도 있었어요 영업시간월-토: 11:30~21:00일요일 휴무브레이크 타임 15:00~17:00영업시간 확인하시고요일요일은 정기 휴무입니다이탈리안 파스타를 하는 곳 치고 21시라는 늦은 시간까지 매장을 운영하는 곳이라 늦은 식사하시는 분들도 방문하기 좋은 곳이에요  한림대맛집 춘천파스타 진스키친의 매장 내부는 이렇게 되어있었는데요한옥을 개조해서 인지 집 같은 느낌이 났고요전체적으로 원목의 테이블과 의자가 분위기와 잘 어울렸어요 거울 셀카 너머 뒤에 보이는 건 진스키친의 주방인데요오픈키친으로 매일 청결에 힘쓰며 위생적인 주방을 유지하기 위해 항상 노력하시고 있다고 해요 딱 봐도 깔끔해 보이죠? 또한 세스코도 가입되어 있는 매장이라고 합니다역시 음식 만드는 곳은 청결이 최우선인 것 같아요 테이블 매트도 있어서 더 정갈한 느낌이 났어요고즈넉한 분위기가 매력인 곳이라 데이트 장소로도 추천해봅니다 메뉴를 고르기 전 먼저 애피타이저를 바로 내주시더라고요한림대맛집 춘천파스타 진스키친에서는 무려 분자요리를 서비스로 주신다는..!과학적으로 접근한 요리법이라니 흥미가 느껴지더라고요 계란 노른자의 모양을 띠고 있어 궁금증을 유발합니다ㅋㅋㅋ잘못 보면 뭐지 계란 노른자를 주시나 할 텐데요사실 오렌지 젤리볼입니다물젤리? 같은 느낌이에요 팡! 하고 터지는 식감이 특징이기 때문에 입에 한꺼번에 넣어야 합니다 잘라먹을 수 없어요..!ㅋㅋㅋ먹어보니 새콤달콤한 맛으로 입맛을 돋워주더라고요  Previous imageNext image메뉴판 한림대맛집 춘천파스타 진스키친의 메뉴판입니다애피타이저를 먹으며 뭘 먹을지 메뉴를 골라봤는데요시그니쳐 메뉴인 아란치니도 먹고 싶고.. 상큼한 샐러드도 땡기고.. 리조또도 먹고 싶고..그래서 런치할인세트 B를 선택했습니다ㅋㅋㅋ메인요리 택2+아란치니 택1+후르츠 미니샐러드 or 음료 중 택 1조합이에요저희는 메인요리로 관자 바질페스토 파스타, 스테이크 크림 리조또를 골랐고요여기에 쉬림프 크림 아란치니, 후르츠 미니샐러드 조합으로 선택했어요거기에 음료수는 따로 추가 주문했습니다  이탈리안 음식 먹을 때 콜라는 필수라고요~ 먼저 후르츠 미니샐러드가 나왔는데요 신선한 샐러드 채소와 후르츠 칵테일 과일 그리고 발사믹 소스가 입안을 깔끔하게 정리해 주더라고요그리고 샐러드 먹으면 왠지 죄책감이 덜 생김ㅎㅎㅎ 다음으로 관자 바질페스토 파스타가 나왔어요바질, 잣, 마늘에 올리브유를 넣고 갈아 만든 바질페스토에 관자를 올린 파스타입니다 스테이크 크림 리조또는 부채살을 구워 올린 크림베이스의 리조또인데요고기는 못참으니까 필수로 시켜줍니다ㅋㅋ 한림대맛집 춘천파스타 진스키친#진스키친#춘천파스타#한림대맛집#춘천양식 영상으로도 보세yo 스테이크 크림 리조또는 생각보다 고기가 많이 올라가 있었는데요쌀알이 톡톡 씹히는 식감이 좋았어요크림소스도 만족해서 잘 골랐다 싶었습니다한림대맛집 맞습니다 고기 념념  관자 바질페스토 파스타는 바질 크림 소스가 꾸덕꾸덕하고 진해서 좋았어요가성비 춘천파스타는 여기서 드세yo 이름에 걸맞게 아쉽지 않도록 관자를 넉넉히 올려줍니다. 굿관자를 좋아하는 저로서는 만족- 새둥지를 표현한 그릇에 샐러드 그리고 그 위에 올라간 아란치니가 새둥지의 새알 같죠ㅋㅋㅋ 귀엽   슥 잘라봅니다 예쁘게 먹기는 실패한..ㅋㅋㅋ 아란치니인데요안에 새우와 크림이 들어가서 눅진한 맛이 특징이에요 휴무일이 월요일에서 일요일로 변경됐고 글 서두에서도 얘기했지만 한림대학교 학생은 전메뉴 10%할인이라고 하니 참고하시고요 평일에는 영수증을 지참하면 진스키친 바로 옆에 있는 카페희랑에서 할인도 받을 수 있다고 하니 카페희랑도 꼭 가보십셔 고즈넉한 분위기가 좋은 한림대맛집 춘천파스타 진스키친한림대 근처에서 이탈리안이 땡기신다면 꼭 가보세요가성비 갑입니다,,☆ 그럼 👋이 글은 가보자체험단을 통해 제품 또는 서비스를 협찬받아 작성된 리뷰입니다 ]
# """
#
# article2 = """
# [입구 이번에 춘천 한림대 맛집으로 교동에 위치한이탈리안 레스토랑 진스키친에 방문했습니다!예전부터 꼭 한번 가봐야지 했었는데, 드디어!(주차는 주변 골목에 주차해야 하더라구요!) 진짜 입구!좁은 길을 따라 들어가다보니,이렇게 한옥 느낌나는 건물이 나오더라구요! 다리 길어보이는 포토존전신거울 또 그냥 못 지나치잖아요?바로 사진 찍어버리기~(다리가 길게 나와요...개꿀..) 와인병 인테리어 내부로 들어가는 입구쪽에는 이렇게와인병들이 반겨주고 있습니다! 야외석아직은 날씨가 춥다보니 앉지는 않았지만,이렇게 밖에도 테이블이 있었습니다!근데, 사실상 실내가 더 이쁜곳이라서!! 주방 및 바 테이블진스키친 가게 안으로 들어서니까 이렇게주방과 바 테이블이 보였습니다!위에 와인잔도 이쁘길래 한컷! 소박한 감성의 인테리어 춘천 한림대 맛집 진스키친의 인테리어는전체적으로 소소하고 따스한 느낌이었습니다! 제가 앉은 자리! 저는 여기 입구에서 가까운 창가쪽 자리에자리를 잡았습니다! 괜찮은 자리였어요!해도 들고 통유리라서 탁 트인게 좋더라구요! 머리조심!안쪽으로는 좀 더 무드한 느낌의 좌석들이준비 되어있었는데요! 예약은 필수! 여긴 어떤 커플손님분들이 이용하셨어요!그런데....춘천 레스토랑 맛집답게 거의 다 예약석...저는 대낮에 방문한거였는데도 전부 예약석!!혹시, 꼭 드셔야 한다면 예약을 하세요! 가장 안쪽에는 넓은 단체석!!저~기 안쪽에 딱봐도 넓은 느낌나는자리 보이시죠? 단체석이더라구요! 프라이빗한 단체석 춘천 레스토랑 진스키친의 단체석은어느정도 단독 분리된 느낌이 있어서,프라이빗함도 느낄 수 있는 자리였어요!단체석도 당연하다는듯이 예약상태... 메뉴판 이제, 다시 저의 자리로 돌아와서메뉴준비를 시작했습니다.제가 주문한 메뉴는 총 4개!1. 베이컨 크림 아란치니2. 강원도 감자밭 뇨끼3. 관자 바질 페스토4. 수비드 삼겹살 스테이크(수비드는 약간의 시간 소요)입니다!콩피 안심 스테이크를 먹으려고 했는데,예약을 하고 와야한다고 하시더라구요!(예약을 못하셨다면 방문 전 연락해보세요!) 식전 특별음식! 춘천 한림대 맛집 진스키친에서는식전에 숟가락에 노른자를 줍니다...갑자기 숟가락에 노른자가 나오길래'뭐지...? 요리에 비벼먹는 건가?' 했는데,오렌지주스 느낌의 분자요리였어요!실제로 먹으면 톡! 터지면서 오렌지주스가 촤악! 첫번째 음식! 가장 먼저 나온 요리는 관자 바질 페스토입니다!역시... 바질은 실패하지 않아요....향긋한 바질향과 야들쫄깃한 관자까지...그냥 크림 파스타 좋아하면 무조건 합격할 맛! 두번째 음식! 아직 맛을 보기도 전에 바로 두번째로 대령한건쫄깃하고 부드러운 강원도 감자밭 뇨끼입니다!뇨끼는 가끔씩 먹어봐서 아직도 식감이 신기한데,트러플 오일이 들어간걸로 기억해요! 톡톡 쏘는 향!(트러플 오일만 안 싫어하시면 무조건 합격!)(음식 특성상 배부릅니다. 양 많아요..ㄷㄷ) 세번째 음식! 이제 막 뇨끼를 먹어보려는데, 두둥등장!수비드 삼겹살 스테이크 입니다!진~짜 너무 맛있어요!! 너~무 부드러워요!!(역시..킹비드 갓비드 빛비드...!)꼭 드세요... 두번 드세요...배터지는 와중에도 이건 다 우겨넣었습니다... 네번째 음식! 그리고, 귀엽다고 방심했다가 배불렀던 그녀석...마지막 음식은 베이컨 크림 아란치니 입니다!그냥 한입거리인줄 알았는데, 생각보다 양이...아란치니만 드시면 좀 물리실 수 있는데,아래 샐러드랑 같이 드시면 굉장히 잘 어울려요!(제가 배터진 이유는 얘랑 뇨끼 때문이에요...) 전체샷처음에 사장님께서 '요리를 한번에 내드릴까요?'라고 여쭤보셔서, 그렇게 해달라고 말씀드렸다가가게에 손님이 갑자기 꽉 차는 바람에하나씩 나올 것 같다고 양해 말씀주셨었는데거의 동시에 내주셔서 전체샷을 찍을 수 있었어요!(사장님, 감사합니다.)  춘천 레스토랑 진스키친 리뷰는 끝입니다!저는 서비스, 가격, 맛 너무 만족스러웠구요!앞으로 더 흥하셨으면 좋겠습니다!(이미, 예약 꽉 차는 곳이지만요...) 50m© NAVER Corp.더보기 /OpenStreetMap지도 데이터x© NAVER Corp. /OpenStreetMap지도 컨트롤러 범례부동산거리읍,면,동시,군,구시,도국가진스키친강원도 춘천시 삭주로 55-1 1층  ]
# """
#
# article3 = """
# [춘천 한림대맛집  파스타맛집 메뉴 가격 런치세트 추천진스키친   안녕하세요 러블리고🌸입니다 오늘 제가 소개해 드릴 곳은 춘천 한림대 앞에 위치하고 있는 춘천 파스타 맛집 "진스키친"이에요 깔끔한 인테리어에 분위기도 좋아 춘천 데이트 코스로도인기가 많은 곳이더라고요 👍  진스키친#한림대맛집 #춘천파스타맛집 #춘천데이트코스📍위치 : 강원 춘천시 삭주로 55-1 1층💡영업시간 : 월-토 11:30-21:00 (B.T 15:00-17:00)매주 일요일 휴무📞 0507-1496-0273⭐️ 골목주차, 당일예약가능, 5인이상 단체손님 전화문의   외관춘천 한림대 맛집 진스키친은 골목에 위치하고 있는데요대로변 골목 입구에 작은 간판과 함께 큼지막한 메뉴 소개 배너가 있어서바로 찾아 들어왔어요 들어가는 길에 조명이 켜져 있어서 은근 사진 찍기 좋은 스팟이더라고요?ㅋㅋ오픈런하느라  매장이 아직 열지 않아서신랑 MZ샷도 찍어주고 놀먼서 기다렸어요 🤭 차량을 가지고 오실 경우에는 전용주차장이 따로 없어서 근처 골목에 주차하시고 오시면 된답니다골목 안쪽으로 들어오면 파란 대문이 진스키친 입구에요 한림대 학생은 항시 전 메뉴 10% 할인 중으로 학생들이 방문하기에도 좋겠어요 🤩   내부입구 파란 대문을 통해 들어오면 너무나도 분위기 좋았던 돌담길이 쭉 펼쳐져있었어요 한옥을 개조해 만든 식당인데 안에 이런 곳이 있었다니너무너무 예쁘더라고요 🩵와인도 같이 판매하고 있는 진스키친은 공병이 야외에진열되어 있었는데 이 또한 인테리어로 한몫했답니다     큼지막한 전신거울도 있어서 사진도 찍어주고요 😆 야외에 테이블과 의자가 있었는데 식사 공간은 아니고웨이팅 하면서 앉아있을 수 있는 거 같았어요 점심시간에는 금방 좌석이 차서 웨이팅 하실 수 있으니예약하고 오시는 걸 추천드릴게요 👍 매장 내부로 들어오면 입구에 바테이블과 함께 주방이 바로 보이더라고요 !! 오픈형 주방이라 요리하는 과정을 볼 수 있어서 이쪽에 앉아도 꽤 좋을 거 같아요? 👀  춘천 한림대맛집 진스키친은 따뜻한 감성을 느낄 수 있는 인테리어로 꾸며져 있었어요 우드소재의 가구들과 함께 창문에 레이스 커튼도 너무 예쁘더라고요 🩵저희는 오픈런 해서 들어왔는데 이미 예약된 자리가 몇 곳 있었어요 역시 인기 많은 파스타 맛집!!!    창가자리는 햇살이 들어오면서 더 따스한 분위기가느껴져 좋았어요 : ) 은은한 조명이 예뻐서 저녁시간에 방문해서 와인 한잔하며 데이트하기에도 좋겠어요  아늑한 실내 곳곳에 식물들이 배치되어 포인트가 되었고조명 또한 세심하게 배치하여 식사할 때 그 은은한 분위기가 좋았답니다    메뉴춘천 한림대맛집 진스키친은 런치할인세트가 있어서 11:30-14:00 에 방문하시면좀 더 저렴한 가격에 세트메뉴를 드실 수 있어요 🫶 식사 메뉴는 아란치니(베이컨/쉬림프) 7,0알리오올리오 12,0 / 초리조파스타 15,0베이컨크림파스타 15,0 / 라구파스타 15,0핫쉬림프파스타 15,0 / 상하이파스타 15,0차돌된장파스타 15,0 / 관자바질페스토 16,0바질페스토 치킨 리조또 15,0 / 스테이크 크림 리조또 16,0수비드 삼겹살 스테이크 23,0후르츠 미니 샐러드 5,0 / 쉬림프 샐러드 12,0그 외에 음료와 와인도 판매중이었어요    주문메뉴런치세트 B 37,0(라구 파스타+스테이크 크림 리조또 +베이컨 아란치니 + 후르츠 미니샐러드)제로콜라 2,0저희는 점심시간에만 먹을 수 있는 가성비 좋은런치세트로 주문했어요 🩵런치세트 기본 구성이 메인요리 택 2 + 아란치니1 + 샐러드 or 음료2잔이라 두명이서 먹기 딱 좋은 메뉴였어요 먼저 에피타이저가 나왔는데계란 노른자처럼 생긴 이 요리는 오렌지 젤리 분자요리에요 탱글탱글한 분자요리는 한입에 쏙 먹으면입안에서 오렌지주스 같은 게 톡 터져서 입맛을 돋우는데아주 좋았답니다   준비된 요리가 하나씩 나오는데 와 다 너무 맛있어 보이는 거예요!! ㅎㅎㅎ 다 나오면 찍으려고 기다리고 있었어요 🤭  후르츠 미니샐러드메인 요리만 먹기 아쉬울 때 꼭 주문하는 샐러드인데 런치세트 메뉴에 있어서 더 마음에 들었는데요 미니 샐러드라는데 양이 엄청 많았어요 🤩 푸짐한 야채와 함께 후르츠과일이 듬뿍 들어가있어서더 맛있었던 후르츠샐러드는 파스타랑도 잘 어울렸어요 단품 가격도 5천원이라 부담스럽지 않게 드실 수 있답니다     베이컨 크림 아란치니진스키친의 시그니처 메뉴인 아란치니 !!특별한 비주얼의 음식이였는데 보기만 해도 바삭함이느껴졌는데요 토마토베이스의 소스가 올라가 더 먹음직스러워보였어요  반으로 자르면 치즈가 쭉 늘어나면서 안에 베이컨과 크림이 듬뿍 들어있더라고요 ㅎㅎ 아란치니 요리는 처음 먹어봤는데 바삭하면서 속의 부드럽고 담백함을 같이 느낄 수 있어서 너무 맛있더라고요 🩵   스테이크 크림 리조또부채살 굽기 정도도 적당했고 고기의 육즙과 함꼐크림 리조또가 잘 어우러져 더 맛있더라고요 &gt;&lt; 식감이 특이하다 싶었는데 진스키친은 보리밥으로 리조또를 만들더라고요 꼬들한 식감이라 더 맛있었어요고소하면서 크리미한 크림소스가 넘 맛있어서 배부른데도 손은 계속 움직이고 있더라고요 🤣리조또에 부채살 올려서 같이 먹으면 완전 꿀맛이랍니다     라구 파스타개인적으로 라구소스를 좋아해서 주문한 라구파스타 토마토베이스에 고기가 듬뿍 들어가서 맛있을 수 밖에 없는 라구파스타이지만 진스키친의 라구파스타는 더 맛있더라고요 !! 간이 완전 세지도 않고 면의 익힘정도도 딱 좋았어요   소스도 넉넉하게 주셔서 숟가락으로 같이 떠서 먹을 만큼넘 맛있었던 라구파스타에요 재방문해서 다시 먹고 싶을만큼 맛있었답니다 역시 파스타맛집 🤩  맛있는건 영상으로 🩵 춘천 한림대맛집 진스키친 파스타맛집 예약필수 메뉴 가격춘천 한림대맛집 진스키친 파스타맛집 예약필수 메뉴 가격#춘천한림대맛집#한림대맛집#춘천데이트#춘천양식#춘천파스타맛집#춘천파스타   한림대 앞에 위치하고 있어서 대학생들 뿐만 아니라데이트코스로도 많이 방문하시는 춘천 파스타맛집 진스키친따뜻하고 편안한 느낌의 분위기도 좋았지만 파스타와 리조또 특히 아란치니까지 너무 맛있었던 식당이였어요 🩵점심에 방문하시면 좀 더 가성비좋은 가격대로 다양한 음식을 드실 수있으니 춘천 파스타 맛집 찾으신다면 추천드릴께요 👍   50m© NAVER Corp.더보기 /OpenStreetMap지도 데이터x© NAVER Corp. /OpenStreetMap지도 컨트롤러 범례부동산거리읍,면,동시,군,구시,도국가진스키친강원특별자치도 춘천시 삭주로 55-1 1층  ]
# """

# 사용 예시
# articles = [article1, article2, article3]  # 여기에 실제 글 내용을 넣으세요
# information = extractor_information(articles)
# print(information)
