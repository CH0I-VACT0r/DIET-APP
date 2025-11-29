import pandas as pd

# 1. 파일 읽기 (본인의 파일명으로 수정하세요)
# 엑셀 파일(.xlsx)이라면 pd.read_excel 사용
filename = '가공식품데이터.csv' 
try:
    df = pd.read_csv(filename, encoding='utf-8')
except:
    df = pd.read_csv(filename, encoding='cp949') # 한글 인코딩 대응

# 2. 필요한 컬럼만 선택하고 영어 이름으로 바꾸기 (매핑)
# 왼쪽: 엑셀 헤더 이름, 오른쪽: 앱에서 쓸 영어 이름
column_mapping = {
    '식품명': 'name',
    '식품대분류명': 'category_big',
    '대표식품명': 'main_name',
    '식품소분류명': 'category_small',
    '영양성분함량기준량': 'serving_size',
    '에너지(kcal)': 'kcal',
    '단백질(g)': 'protein',
    '지방(g)': 'fat',
    '탄수화물(g)': 'carbs',
    '당류(g)': 'sugar',
    '나트륨(mg)': 'sodium',
    '콜레스테롤(mg)': 'cholesterol',
    '포화지방산(g)': 'saturated_fat',
    '트랜스지방산(g)': 'trans_fat'
}

# 컬럼 이름 변경
df = df.rename(columns=column_mapping)

# 매핑된 컬럼만 남기기 (오류 방지)
df = df[list(column_mapping.values())]

# 3. 결측치(빈칸) 처리 - 빈칸은 0이나 빈 문자열로 채움
df = df.fillna(0) 

# 4. JSON으로 저장 (한글 깨짐 방지 옵션 포함)
output_file = 'food_data.json'
df.to_json(output_file, orient='records', force_ascii=False, indent=2)

print(f"변환 완료! {output_file} 파일이 생성되었습니다.")