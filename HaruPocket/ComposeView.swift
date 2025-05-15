//
//  ComposeView.swift
//  HaruPocket
//
//  Created by 장지현 on 5/12/25.
//

import SwiftUI
import SwiftData
import PhotosUI

/// 소비 내역 입력 폼의 각 필드 타입을 나타냅니다.
enum FieldType: Int, Hashable {
    case title
    case money
    case content
}

/// 사용자가 소비 내역을 작성하는 화면입니다.
/// 이미지를 첨부하거나, 날짜, 카테고리, 제목, 금액, 내용을 입력할 수 있습니다.
/// 새로운 항목을 생성하거나 기존 항목을 수정할 수 있습니다.
struct ComposeView: View {
    @AppStorage("username") private var username: String = "default_user"

    @EnvironmentObject var spendingViewModel: SpendingViewModel

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State var date: Date
    @State private var selectedCategory: Category?
    @State private var presentModal: Bool = false
    @State private var title: String = ""
    @State private var money: String = ""
    @State private var content: String = ""
    @State private var img: String = ""
    @State private var showTitleAlert = false
    @State private var showMoneyAlert = false
    @State var selectedItem: PhotosPickerItem?
    @State var showImage: Image?

    @FocusState private var focused: FieldType?

    @Binding var basics: BasicEntry?

    var body: some View {
        ScrollViewReader {proxy in
            ScrollView {
                VStack {
                    PhotosPicker(selection: $selectedItem) {
                        if let image = self.showImage {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .frame(width: 360)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                        } else if let uiImage = basics?.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .frame(width: 360)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .tint(Color.lightPointColor)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .frame(height: 250)
                                .frame(width: 360)
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.lightPointColor, lineWidth: 1)
                    }
                    .padding(.bottom)
                    .onChange(of: selectedItem) { oldValue, newValue in
                        Task {
                            await convertImage(item: newValue)
                        }
                    }

                    Grid(verticalSpacing: 20) {
                        GridRow {
                            HStack {
                                VStack(spacing: 5) {
                                    Text("작성 날짜")
                                        .font(.callout)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 10)

                                    Text(date, style: .date)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.lightPointColor, lineWidth: 1)
                                        }
                                        .overlay {
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
                                    let allCategories = spendingViewModel.categories
                                    let categories = allCategories.filter {
                                        $0.userID == spendingViewModel.username
                                    }

                                    if categories.count <= 6 {
                                        SelectCategoryByMenu(selectedCategory: $selectedCategory, basics: $basics, categories: categories)
                                    } else {
                                        SelectCategoryBySheet(presentModal: $presentModal, selectedCategory: $selectedCategory, basics: $basics)
                                    }
                                }
                            }
                        }

                        GridRow {
                            VStack(spacing: 5) {
                                Text("제목")
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)

                                HStack {
                                    TextField("제목", text: $title)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .focused($focused, equals: .title)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.lightPointColor, lineWidth: 1)
                                }

                            }
                        }

                        GridRow {
                            VStack(spacing: 5) {
                                Text("가격")
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)

                                HStack {
                                    TextField("가격", text: $money)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .focused($focused, equals: .money)
                                        .keyboardType(.numberPad)
                                        .onChange(of: money) {
                                            money = money.filter { $0.isNumber }
                                        }

                                    Text("원")
                                        .padding(.horizontal)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.lightPointColor, lineWidth: 1)
                                }
                            }
                        }

                        GridRow {
                            VStack(spacing: 5) {
                                Text("내용")
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)

                                HStack {
                                    TextEditor(text: $content)
                                        .padding()
                                        .frame(maxWidth: .infinity, minHeight: 150, maxHeight: .infinity, alignment: .leading)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .focused($focused, equals: .content)
                                        .scrollIndicators(.hidden)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.lightPointColor, lineWidth: 1)
                                }

                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()

                            Button(focused != .content ? "next" : "done") {
                                switch focused {
                                case .title:
                                    focused = .money
                                case .money:
                                    focused = .content
                                case .content:
                                    focused = nil
                                case .none:
                                    focused = nil
                                }
                            }
                        }
                    }

                }
                .padding()
                .onAppear {
                    spendingViewModel.loadCategory(context: context)

                    if let basics {
                        self.date = basics.date
                        title = basics.title
                        money = String(basics.money)
                        content = basics.content ?? ""
                        img = basics.imageFileName ?? ""
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
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
                        Text(formattedDate(from: basics?.date) ?? "새로운 소비")
                            .font(.title2)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            save()
                        } label: {
                            Text("완료")
                                .font(.title3)
                                .foregroundColor(Color.lightPointColor)
                        }
                    }
                }
                .environment(\.locale, Locale(identifier: "ko_kr"))
                .sheet(isPresented: $presentModal) {
                    SelectCategoryView { item in
                        selectedCategory = item
                        presentModal = false
                    }
                }
                .alert("경고", isPresented: $showTitleAlert) {
                    Button {
                        focused = .title
                    } label: {
                        Text("확인")
                    }
                } message: {
                    Text("제목을 입력해 주세요")
                }
                .alert("경고", isPresented: $showMoneyAlert) {
                    Button {
                        focused = .money
                    } label: {
                        Text("확인")
                    }
                } message: {
                    Text("가격을 입력해 주세요")
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

extension ComposeView {
    /// 소비 내역을 저장하는 함수입니다.
    /// 입력된 제목, 금액, 내용, 날짜, 이미지, 카테고리를 기반으로 새로운 항목을 생성하거나 기존 항목을 수정합니다.
    func save() {
        if title.isEmpty {
            showTitleAlert = true
        } else if money.isEmpty {
            showMoneyAlert = true
        } else {
            if let basics {
                basics.title = title
                basics.money = Int(money) ?? 0
                basics.content = content
                basics.date = date
                basics.imageFileName = img
                basics.category = selectedCategory ?? basics.category
            } else {

                let newEntry = BasicEntry(
                    title: title,
                    content: content,
                    date: date,
                    money: Int(money) ?? 0,
                    imageFileName: img,
                    userID: username,
                    category: selectedCategory
                )
                context.insert(newEntry)
            }

            do {
                try context.save()
                dismiss()
            } catch {
                print("저장 실패: \(error.localizedDescription)")
            }
        }
    }

    /// Date 값을 한국어 형식의 문자열로 변환합니다.
    /// - Parameter date: 변환할 날짜
    /// - Returns: 변환된 날짜 문자열
    func formattedDate(from date: Date?) -> String? {
        guard let date else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .long
        formatter.timeStyle = .none

        return formatter.string(from: date)
    }

    /// 선택된 PhotosPickerItem을 UIImage로 변환하여 화면에 표시하고, 문서 디렉토리에 저장합니다.
    /// - Parameter item: 선택된 PhotosPickerItem
    func convertImage(item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.showImage = Image(uiImage: uiImage)

        if let filename = saveImageToDocuments(uiImage: uiImage) {
            self.img = filename
        }
    }

    /// UIImage를 JPEG 형식으로 문서 디렉토리에 저장합니다.
    /// - Parameter uiImage: 저장할 UIImage
    /// - Returns: 저장된 파일 이름
    func saveImageToDocuments(uiImage: UIImage) -> String? {
        guard let jpegData = uiImage.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

        do {
            try jpegData.write(to: url)
            print("저장된 경로:", url.path)
            return filename
        } catch {
            print("이미지 저장 실패: \(error)")
            return nil
        }
    }
}

#Preview("Update") {
    NavigationStack {
        ComposeView(date: Date(), basics: .constant(BasicEntry(
            title: "샘플 이미지 항목 1",
            content: "테스트용 이미지가 포함된 항목입니다. 테스트용 이미지가 포함된 항목입니다.",
            date: Date(),
            money: 42494,
            imageFileName: "SampleImage/gift.jpg",
            userID: "default_user",
            category: Category(
                name: "테스트",
                color: .blue,
                emoji: "💡",
                userID: "default_user"
            ))))
        .modelContainer(
            for: [BasicEntry.self, Category.self],
            inMemory: true
        )
        .environmentObject(SpendingViewModel())
    }
}

#Preview("Create") {
    NavigationStack {
        ComposeView(date: Date(), basics: .constant(nil))
            .modelContainer(
                for: [BasicEntry.self, Category.self],
                inMemory: true
            )
            .environmentObject(SpendingViewModel())
    }
}

/// 카테고리 개수가 6개 이하일 때, Menu 형태로 카테고리를 선택할 수 있는 뷰입니다.
struct SelectCategoryByMenu: View {
    @Binding var selectedCategory: Category?
    @Binding var basics: BasicEntry?
    let categories: [Category]
    var currentCategory: Category? {
        selectedCategory ?? basics?.category
    }

    var body: some View {
        Menu {
            Button {
                // FIXME: CategoryComposeView Push
            } label: {
                Label("새로운 카테고리", systemImage: "plus")
            }

            ForEach(categories) { category in
                Button {
                    selectedCategory = category
                } label: {
                    Text(category.name)

                    if category == selectedCategory {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            HStack(spacing: 2) {
                HStack(spacing: 2) {
                    Text(currentCategory?.name ?? "카테고리 선택")
                        .tint(currentCategory == nil ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let category = currentCategory {
                        Text(category.emoji)
                            .font(.footnote)
                            .padding(7)
                            .background(category.color)
                            .clipShape(Circle())
                            .frame(maxHeight: 10)
                    }

                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.lightPointColor)
                }
            }
            .padding()
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.lightPointColor, lineWidth: 1)
        }
    }
}

/// 카테고리 개수가 7개 이상일 때, 시트로 카테고리를 선택할 수 있는 버튼 뷰입니다.
struct SelectCategoryBySheet: View {
    @Binding var presentModal: Bool
    @Binding var selectedCategory: Category?
    @Binding var basics: BasicEntry?

    var currentCategory: Category? {
        selectedCategory ?? basics?.category
    }

    var body: some View {
        Button {
            presentModal = true
        } label: {
            Text(currentCategory?.name ?? "카테고리 선택")
                .tint(currentCategory == nil ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let category = currentCategory {
                Text(category.emoji)
                    .font(.footnote)
                    .padding(7)
                    .background(category.color)
                    .clipShape(Circle())
                    .frame(maxHeight: 10)
            }

            Image(systemName: "chevron.right")
                .foregroundStyle(Color.lightPointColor)
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.lightPointColor, lineWidth: 1)
        }
    }
}
