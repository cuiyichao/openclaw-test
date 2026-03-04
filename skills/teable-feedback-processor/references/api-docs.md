# Teable API 文档

## 配置信息

- **Base URL**: `https://yach-teable.zhiyinlou.com`
- **Table ID**: `tblJR0Vtfhc7wQcTi4i`
- **API Token**: `teable_accQVUtYuMEYwAvrdoG_Wxut/BNgFUPHTbNT2gzBlddSHR/cxU5Ge3pWrFpcW4g=`
- **Endpoint**: `/api/table/tblJR0Vtfhc7wQcTi4i/record`

## 字段定义

| 字段名 | 字段 ID | 类型 | 说明 |
|--------|---------|------|------|
| ID | `fldOBNzOWwRWZGpbWYU` | Single line text | 主键 [PRIMARY] |
| Queid | `fldGkaYJSEkIsOLvu8N` | Number | 问题编号（数字） |
| 问题详情 | `fldYl5B36vcJw3VrT8r` | Long text | 问题描述 |
| 反馈人 | `fldNq5BLO35C5vKzwcI` | Single line text | 反馈者姓名 |
| 反馈时间 | `fld6xVziDMcwsOIGsSs` | Created time | 自动生成的创建时间 [READ-ONLY] |
| 状态 | `fldYNSMm5cN4bGNWVj5` | Single select | 未解决 / 已解决 |

## API 操作

### 1. 读取记录 (GET)

```bash
curl -X GET "https://yach-teable.zhiyinlou.com/api/table/tblJR0Vtfhc7wQcTi4i/record?fieldKeyType=name" \
  -H "Authorization: Bearer teable_accQVUtYuMEYwAvrdoG_Wxut/BNgFUPHTbNT2gzBlddSHR/cxU5Ge3pWrFpcW4g="
```

**分页参数**:
- `take`: 返回记录数 (默认 100, 最大 1000)
- `skip`: 跳过记录数

**过滤参数** (⚠️ 必须使用 fieldId):
```bash
filter={"conjunction":"and","filterSet":[{"fieldId":"fldOBNzOWwRWZGpbWYU","operator":"is","value":"Q001"}]}
```

**排序参数** (⚠️ 必须使用 fieldId):
```bash
orderBy=[{"fieldId":"fld6xVziDMcwsOIGsSs","order":"desc"}]
```

### 2. 创建记录 (POST)

```bash
curl -X POST "https://yach-teable.zhiyinlou.com/api/table/tblJR0Vtfhc7wQcTi4i/record" \
  -H "Authorization: Bearer teable_accQVUtYuMEYwAvrdoG_Wxut/BNgFUPHTbNT2gzBlddSHR/cxU5Ge3pWrFpcW4g=" \
  -H "Content-Type: application/json" \
  -d '{
    "fieldKeyType": "name",
    "records": [{
      "fields": {
        "ID": "Q001",
        "Queid": 1,
        "问题详情": "问题描述内容",
        "反馈人": "张三",
        "状态": "未解决"
      }
    }]
  }'
```

### 3. 更新记录 (PATCH)

```bash
curl -X PATCH "https://yach-teable.zhiyinlou.com/api/table/tblJR0Vtfhc7wQcTi4i/record/{recordId}" \
  -H "Authorization: Bearer teable_accQVUtYuMEYwAvrdoG_Wxut/BNgFUPHTbNT2gzBlddSHR/cxU5Ge3pWrFpcW4g=" \
  -H "Content-Type: application/json" \
  -d '{
    "fieldKeyType": "name",
    "record": {
      "fields": {
        "状态": "已解决"
      }
    }
  }'
```

### 4. 删除记录 (DELETE)

```bash
curl -X DELETE "https://yach-teable.zhiyinlou.com/api/table/tblJR0Vtfhc7wQcTi4i/record/{recordId}" \
  -H "Authorization: Bearer teable_accQVUtYuMEYwAvrdoG_Wxut/BNgFUPHTbNT2gzBlddSHR/cxU5Ge3pWrFpcW4g="
```

## 过滤器操作符

### 文本字段
- `is`, `isNot`, `contains`, `doesNotContain`, `isEmpty`, `isNotEmpty`

### 数字字段
- `is`, `isNot`, `isGreater`, `isLess`, `isGreaterEqual`, `isLessEqual`

### 日期字段
- `is`, `isBefore`, `isAfter`, `isWithin`

## 注意事项

1. **fieldKeyType**: 请求和响应中使用字段名（name）而非字段 ID
2. **filter/orderBy**: 必须使用字段 ID（如 `fldOBNzOWwRWZGpbWYU`）
3. **READ-ONLY 字段**: `反馈时间` 是自动生成的，不能直接修改
4. **PRIMARY 字段**: `ID` 是主标识字段
