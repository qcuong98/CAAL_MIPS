# Coding conventions

- Hàm được gọi phải phục hồi các thanh ghi `$s0-7`, `$sp`, `$ra` như ban đầu (nếu có sử dụng).
- Hạm gọi phải lưu các thanh ghi `$t0-7`, `$a0-4`, `$v0-1` nếu muốn sử dụng lại sau khi gọi hàm khác.
- Trong hàm nếu dùng label thì thêm tên hàm trước tên label: `TênHàm_TênLabel:`.
- Khi viết hàm nhớ thêm label phía sau hàm và lệnh nhảy trước hàm:
```
j EndFunc
Func:
...
...
...
EndFunc:
```
- Gán giá trị cho thanh ghi: dùng `or` hoặc `ori`
- Cộng, trừ dùng lệnh có `u` (để không crash khi tràn số): `addu`, `subu`, `addiu`

# Các hàm nhập và kiểm tra dữ liệu

## int IsValidTime(int day, int month, int year)

- `0 <= year <= 9999`
- `1 <= month <= 12`
- `day` giới hạn tùy tháng

**Các hàm sau có kết quả trả về ở v0, nếu dữ liệu không hợp lệ thì v1 có giá trị khác 0,
ngược lại v1 = 0**

## char *ScanStr()

Nhập và kiểm tra chuỗi vừa nhập có định dạng hợp lệ không.
Chỉ cần kiểm tra xem chuỗi có dạng XX/XX/XXXX hay không (X từ 0 đến 9),
không cần kiểm tra giá trị của ngày, tháng.

Không cho phép khoảng trắng ở đầu chuỗi nhập vào.

Cho phép khoảng trắng ở cuối chuỗi nhập vào.

## int ScanInt()

Nhập vào một số dương.

Dùng SYSCALL nhập chuỗi sau đó xử lý chuyển sang số.

## char ScanType()

Nhập vào kiểu định dạng chuỗi (‘A’, ‘B’ hoặc ‘C’).

Dùng SYSCALL nhập chuỗi sau đó kiểm tra và trả về kí tự đầu.

# Các hàm trong yêu cầu

Các hàm dưới không cần kiểm tra dữ liệu đầu vào.

## char* Date(int day, int month, int year, char* TIME)

Xuất chuỗi TIME theo định dạng DD/MM/YYYY, trả về TIME

**Các hàm phía sau có TIME nhập vào theo định dạng DD/MM/YYYY**

## int Day(char* TIME), int Month(char* TIME), int Year(char* TIME)

Trả về ngày, tháng, năm.

## char* Convert(char* TIME, char type)

Chuyển định dạng chuỗi TIME (ghi đè lên TIME), trả về TIME. Định dạng:
- ‘A’: MM/DD/YYYY
- ‘B’: Month DD, YYYY
- ‘C’: DD Month, YYYY

'Month' dùng tên tháng đầy đủ (January,...)

## int LeapYear(char* TIME)

Kiểm tra xem TIME có phải là năm nhuận hay không.

## int  GetTime(char* TIME_1, char* TIME_2)

Trả về thời gian cách biệt giữa TIME_1 và TIME_2, giá trị trả về >= 0.

Trả về số năm cách biệt hoặc số ngày cách biệt tùy theo người cài quyết định.

## char* Weekday(char* TIME)

Cho biết TIME là thứ mấy trong tuần.

Giá trị trả về: {Mon, Tues, Wed, Thurs, Fri, Sat, Sun}
