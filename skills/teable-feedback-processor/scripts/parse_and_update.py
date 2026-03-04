#!/usr/bin/env python3
"""
Teable 反馈处理器 - 解析消息并更新表格
"""

import json
import sys
import urllib.request
import urllib.error
from typing import Optional, Dict, Any

# Teable API 配置
TEABLE_CONFIG = {
    "base_url": "https://yach-teable.zhiyinlou.com",
    "table_id": "tblJR0Vtfhc7wQcTi4i",
    "token": "teable_accQVUtYuMEYwAvrdoG_Wxut/BNgFUPHTbNT2gzBlddSHR/cxU5Ge3pWrFpcW4g=",
    "endpoint": "/api/table/tblJR0Vtfhc7wQcTi4i/record"
}

# 字段 ID 映射（用于 filter/orderBy）
FIELD_IDS = {
    "ID": "fldOBNzOWwRWZGpbWYU",
    "Queid": "fldGkaYJSEkIsOLvu8N",
    "问题详情": "fldYl5B36vcJw3VrT8r",
    "反馈人": "fldNq5BLO35C5vKzwcI",
    "反馈时间": "fld6xVziDMcwsOIGsSs",
    "状态": "fldYNSMm5cN4bGNWVj5"
}


def parse_message_with_llm(message: str, llm_response: str) -> Dict[str, Any]:
    """
    解析 LLM 返回的结构化数据
    
    期望 LLM 返回 JSON 格式：
    {
        "id": "问题 ID",
        "description": "问题描述",
        "reporter": "反馈人",
        "status": "未解决" | "已解决"
    }
    """
    try:
        # 尝试从 LLM 响应中提取 JSON
        data = json.loads(llm_response)
        return {
            "id": data.get("id", ""),
            "description": data.get("description", message),
            "reporter": data.get("reporter", "未知"),
            "status": data.get("status", "未解决")
        }
    except json.JSONDecodeError:
        # 如果解析失败，返回默认结构
        return {
            "id": "",
            "description": message,
            "reporter": "未知",
            "status": "未解决"
        }


def find_record_by_id(record_id: str) -> Optional[Dict[str, Any]]:
    """根据 ID 查找现有记录"""
    if not record_id:
        return None
    
    url = f"{TEABLE_CONFIG['base_url']}{TEABLE_CONFIG['endpoint']}"
    
    # 构建 filter - 使用 field ID
    filter_json = {
        "conjunction": "and",
        "filterSet": [
            {
                "fieldId": FIELD_IDS["ID"],
                "operator": "is",
                "value": record_id
            }
        ]
    }
    
    params = f"?fieldKeyType=name&filter={urllib.parse.quote(json.dumps(filter_json))}"
    request_url = url + params
    
    req = urllib.request.Request(request_url)
    req.add_header("Authorization", f"Bearer {TEABLE_CONFIG['token']}")
    
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            records = data.get("records", [])
            return records[0] if records else None
    except urllib.error.URLError as e:
        print(f"查找记录失败：{e}", file=sys.stderr)
        return None


def create_record(fields: Dict[str, Any]) -> Dict[str, Any]:
    """创建新记录"""
    url = f"{TEABLE_CONFIG['base_url']}{TEABLE_CONFIG['endpoint']}"
    
    payload = {
        "fieldKeyType": "name",
        "records": [{
            "fields": fields
        }]
    }
    
    req = urllib.request.Request(url, method="POST")
    req.add_header("Authorization", f"Bearer {TEABLE_CONFIG['token']}")
    req.add_header("Content-Type", "application/json")
    req.data = json.dumps(payload).encode()
    
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode())
    except urllib.error.URLError as e:
        print(f"创建记录失败：{e}", file=sys.stderr)
        return {"error": str(e)}


def update_record(record_id: str, fields: Dict[str, Any]) -> Dict[str, Any]:
    """更新现有记录"""
    url = f"{TEABLE_CONFIG['base_url']}{TEABLE_CONFIG['endpoint']}/{record_id}"
    
    payload = {
        "fieldKeyType": "name",
        "record": {
            "fields": fields
        }
    }
    
    req = urllib.request.Request(url, method="PATCH")
    req.add_header("Authorization", f"Bearer {TEABLE_CONFIG['token']}")
    req.add_header("Content-Type", "application/json")
    req.data = json.dumps(payload).encode()
    
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode())
    except urllib.error.URLError as e:
        print(f"更新记录失败：{e}", file=sys.stderr)
        return {"error": str(e)}


def process_feedback(message: str, llm_response: str, reporter: str = "未知") -> Dict[str, Any]:
    """
    主处理函数：解析消息并更新表格
    
    Args:
        message: 原始消息
        llm_response: LLM 解析后的 JSON 响应
        reporter: 反馈人（可选，优先使用 LLM 返回的）
    
    Returns:
        处理结果
    """
    # 解析 LLM 响应
    parsed = parse_message_with_llm(message, llm_response)
    
    # 如果调用方提供了 reporter 且 LLM 没返回，使用调用方的
    if reporter and reporter != "未知" and not parsed.get("reporter"):
        parsed["reporter"] = reporter
    
    # 构建字段数据
    fields = {
        "ID": parsed["id"],
        "Queid": int(parsed["id"].replace("Q", "")) if parsed["id"].startswith("Q") and parsed["id"][1:].isdigit() else None,
        "问题详情": parsed["description"],
        "反馈人": parsed["reporter"],
        "状态": parsed["status"]
    }
    
    # 清理 None 值
    fields = {k: v for k, v in fields.items() if v is not None}
    
    # 查找现有记录
    if parsed["id"]:
        existing = find_record_by_id(parsed["id"])
        
        if existing:
            # 更新现有记录
            result = update_record(existing["id"], fields)
            result["action"] = "updated"
            return result
        else:
            # 创建新记录
            result = create_record(fields)
            result["action"] = "created"
            return result
    else:
        # 没有 ID，创建新记录
        result = create_record(fields)
        result["action"] = "created"
        return result


if __name__ == "__main__":
    # 命令行测试
    if len(sys.argv) >= 3:
        message = sys.argv[1]
        llm_response = sys.argv[2]
        reporter = sys.argv[3] if len(sys.argv) > 3 else "未知"
        
        result = process_feedback(message, llm_response, reporter)
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print("用法：python parse_and_update.py <消息> <LLM 响应> [反馈人]")
        sys.exit(1)
