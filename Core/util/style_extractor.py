# -*- coding: utf-8 -*-

import os
from dotenv import load_dotenv
from langchain.chat_models import ChatOpenAI
from langchain.prompts import ChatPromptTemplate, PromptTemplate

load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

def extractor_style(articles):
    chat = ChatOpenAI(
        model="gpt-4o-mini",
        max_tokens=1500,
        temperature=0.1,
    )

    # 시스템 메시지 템플릿
    system_message = """
        당신은 블로그/SNS 작문 스타일 분석 및 추출 전문가입니다.
        주어진 블로그 포스트나 SNS 콘텐츠의 작문 스타일을 세밀하게 분석하고, 핵심 스타일 요소를 추출해야 합니다.
        이 분석은 유사한 스타일로 새로운 블로그/SNS 콘텐츠를 생성하는 데 직접 활용될 것입니다.
        
        분석 결과는 다음 카테고리로 구분하고 형태에 맞게 제공하세요:
        
        글 1 작문 스타일:
        1. 문장 구조 (평균 문장 길이, 복문/단문 비율, 문장 시작 패턴 등)
        2. 어휘 선택 (단어 수준, 전문 용어 사용, 은유/직유 사용 빈도 등)
        3. 톤과 목소리 (격식체/비격식체, 감정적/객관적, 직접적/간접적 등)
        4. 수사적 장치 (반복, 대구법, 설의법, 과장법 등의 사용)
        5. 단락 구성 (단락 길이, 논리 흐름, 전환 방식 등)
        6. 특징적 표현 (작가만의 독특한 표현이나 문구 패턴)
        
        각 카테고리별로 최소 3개 이상의 구체적인 예시를 원문에서 발췌하여 포함하세요.
        
        블로그 포스트와 SNS 글의 길이 차이를 고려하여:
        짧은 SNS 글(300자 미만): 2, 3, 7 카테고리에 중점
        중간 길이 글(300-1000자): 모든 카테고리 균형 있게 분석
        긴 블로그 포스트(1000자 이상): 1, 4, 5 카테고리에 더 깊은 분석 추가
        
        분석 결과 마지막에는 "스타일 요약" 섹션을 추가하여:

        1. 이 작성자 스타일의 가장 두드러진 5가지 특징
        2. 이 스타일로 새 콘텐츠 작성 시 반드시 포함해야 할 3가지 핵심 요소
        3. 독자 참여를 극대화하는 이 작성자만의 특별한 기법
        
        최종 분석은 완전히 다른 주제에 관한 새 블로그/SNS 글을 작성할 때도 원작자의 목소리와 스타일을 정확히 재현할 수 있을 만큼 구체적이고 실용적이어야 합니다.
        """

    # 인간 메시지 템플릿
    human_message = """
        검색 키워드에 상단 노출되어있는 블로그/SNS {article_count}개의 작문 스타일을 분석하고 핵심 스타일 요소를 추출해주세요:
        
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

    style_chain = messages | chat

    print("작문 스타일 추출 중...")

    style_final_chain = style_chain.invoke({
        "article_count": len(articles),
        "article_contents": article_contents
    })

    print("작문 스타일 추출 완료!")

    return style_final_chain
