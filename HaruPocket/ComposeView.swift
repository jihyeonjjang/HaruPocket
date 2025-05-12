//
//  ComposeView.swift
//  HaruPocket
//
//  Created by 장지현 on 5/12/25.
//

import SwiftUI

// FIXME: 임시
enum TemporaryCategory: String, Identifiable, Hashable, CaseIterable {
    case food = "음식"
    case shopping = "쇼핑"

    var id: Self { return self }
}

struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date.now // FIXME: 홈뷰에서 선택한 날짜 넘겨받아야함
    @State private var category: TemporaryCategory? = .food
    @State private var title: String = ""
    @State private var money: String = ""
    @State private var content: String = ""
    @State private var img: String = ""

    var body: some View {
        VStack {
            Button {
                print("이미지 버튼 클릭")
            } label: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .tint(Color.lightPointColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            }
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.lightPointColor, lineWidth: 1)
            }
            .padding(.vertical)

            Grid(verticalSpacing: 20) {
                GridRow {
                    HStack {
                        VStack(spacing: 5) {
                            Text("작성 날짜")
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)

                            // TODO: 날짜 포맷팅
                            Text(date, style: .date)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.lightPointColor, lineWidth: 1)
                                }
                                .overlay {
                                    // TODO: 더 좋은 방법이 있을까?
                                    DatePicker("작성 날짜", selection: $date, displayedComponents: .date)
                                        .frame(maxWidth: .infinity)
                                        .labelsHidden()
                                        .colorMultiply(.clear)
                                }
                        }

                        VStack(spacing: 5) {
                            Text("카테고리")
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)

                            Menu {
                                ForEach(TemporaryCategory.allCases) { item in
                                    Button {
                                        category = item
                                    } label: {
                                        Text(item.rawValue)

                                        if item == category {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 2) {
                                    Text(category?.rawValue ?? "카테고리 없음")
                                        .tint(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    // 1번
                                    //                                    Text("🍚")
                                    //                                        .font(.footnote)
                                    //                                        .padding(7)
                                    //                                        .background(.red)
                                    //                                        .clipShape(Circle())

                                    //                                    Text("🍚")
                                    //                                        .font(.footnote)

                                    Circle()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.red)


                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.lightPointColor)
                                }
                                .padding()
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.lightPointColor, lineWidth: 1)
                            }
                        }
                    }
                }

                GridRow {
                    HStack {
                        VStack(spacing: 5) {
                            Text("제목")
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)

                            TextField("제목", text: $title)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.lightPointColor, lineWidth: 1)
                                }
                        }
                    }
                }

                GridRow {
                    HStack {
                        VStack(spacing: 5) {
                            Text("가격")
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)

                            TextField("가격", text: $money)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.lightPointColor, lineWidth: 1)
                                }
                        }
                    }
                }

                GridRow {
                    HStack {
                        VStack(spacing: 5) {
                            Text("내용")
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 10)

                            TextField("내용", text: $content)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.lightPointColor, lineWidth: 1)
                                }
                        }
                    }
                }


            }

        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.lightPointColor)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("제목입력")
                    .font(.title2)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // TODO: SwiftData 저장 로직 구현
                } label: {
                    Text("완료")
                        .font(.title3)
                        .foregroundColor(Color.lightPointColor)
                }
            }
        }
    }

}

#Preview {
    NavigationStack {
        ComposeView()
    }
}
