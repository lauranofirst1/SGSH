# -*- coding: utf-8 -*-

import os
from dotenv import load_dotenv
from langchain.chat_models import ChatOpenAI
from langchain.prompts import ChatPromptTemplate, PromptTemplate

load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

def generator_article(articles, platform):
    chat = ChatOpenAI(
        model="gpt-4o-mini",
        max_tokens=1500,
        temperature=0.4,
    )

    # 시스템 메시지 템플릿
    system_message = """
        당신은 매력적인 상점 콘텐츠를 작성하는 전문 카피라이터입니다.
        상단 노출 블로그/SNS 글의 핵심 키워드, 작문 스타일, 추출된 정보를 바탕으로 매력적인 글을 작성해주세요.
        """

    # 인간 메시지 템플릿
    human_message = """
        다음 정보를 바탕으로 {platform}에 게시할 글을 작성해주세요:
        
        글 정보:
        {information}
        
        글 작문 스타일 참고
        {style}
        
        글 핵심 키워드
        {keywords}
        
        세부 지침
        - 제공된 키워드({keywords})를 자연스럽게 포함시키되, 과도한 반복은 피하세요
        - 스타일을 일관되게 유지하세요
        - 진정성 있고 신뢰할 수 있는 내용으로 작성하세요
        - 실제 경험에 근거한 것처럼 생생한 묘사를 포함하세요
        - 독자의 공감을 얻을 수 있는 감성적 요소를 추가하세요
        - 시각적으로 글이 매력적으로 보이도록 단락을 적절히 나누세요
        
        이 글의 목표는 독자들이 실제로 상점을 방문하고 싶게 만드는 것입니다. 상점의 분위기와 특별함이 느껴지도록 생생하게 작성해주세요.
        """

    messages = ChatPromptTemplate.from_messages([
        ("system", system_message),
        ("human", human_message)
    ])

    generator_chain = messages | chat

    return generator_chain

