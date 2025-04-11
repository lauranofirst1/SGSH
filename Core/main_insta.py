from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from supabase import create_client, Client
import os
from dotenv import load_dotenv
from util import style_extractor, information_extractor, generator, keyword_extractor, generator_insta

# 환경 변수 로드
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# Supabase 클라이언트 초기화
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# 키워드 추출 시 사용할 고정된 max_items 값
MAX_KEYWORDS = 10

app = FastAPI()


class GenerationRequest(BaseModel):
    platform: str

class Article(BaseModel):
    id: int
    content: str
    platform: str

@app.post("/generate")
async def realtime_generation(request: GenerationRequest):
    try:
        response = supabase.table('business_data') \
            .select('*') \
            .eq('id', 1) \
            .execute()

        if not response.data:
            raise HTTPException(status_code=404, detail="No articles found")

        name = [item['name'] for item in response.data]
        address = [item['address'] for item in response.data]
        time = [item['time'] for item in response.data]
        number = [item['number'] for item in response.data]

        print(response.data)

        articles = [name, address, time, number]


        generated_content = main(platform="instagram", articles=articles)

        # print(generated_content)
        # print(articles)

        return {
            # "platform": request.platform,
            "generated_content": generated_content
        }

    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def main(articles, platform="instagram"):
    # information_chain = information_extractor.extractor_information(articles=articles)
    # style_chain = style_extractor.extractor_style(articles=articles)
    # keyword_chain = keyword_extractor.extractor_keywords(articles=articles, max_items=MAX_KEYWORDS)

    # generator_chain = generator.generator_article(articles, platform)
    generator_chain = generator_insta.generator_article(())

    return generator_chain.invoke({
        "platform": platform,
        "name": articles[0],
        "address": articles[1],
        "time": articles[2],
        "number": articles[3],

        # "information": information_chain,
        # "style": style_chain,
        # "keywords": keyword_chain,
    }).content
