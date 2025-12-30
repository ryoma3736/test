//
//  RecordInputView.swift
//  AlcoholTracker
//
//  飲酒記録入力画面
//

import SwiftUI
import SwiftData

struct RecordInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDrinkType: DrinkType?
    @State private var amount: Double = 350
    @State private var alcoholPercentage: Double = 5.0
    @State private var dateTime: Date = Date()
    @State private var note: String = ""
    @State private var showingDrinkPicker = false

    private let drinkTypes = DrinkType.defaultTypes

    var body: some View {
        NavigationStack {
            Form {
                // 飲み物選択セクション
                Section {
                    Button(action: { showingDrinkPicker = true }) {
                        HStack {
                            if let drinkType = selectedDrinkType {
                                Text(drinkType.emoji)
                                    .font(.largeTitle)
                                VStack(alignment: .leading) {
                                    Text(drinkType.name)
                                        .foregroundStyle(.primary)
                                    Text(drinkType.category)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.orange)
                                Text("飲み物を選択")
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("飲み物")
                }

                // 量の入力
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("量")
                            Spacer()
                            Text("\(Int(amount)) ml")
                                .fontWeight(.semibold)
                        }

                        Slider(value: $amount, in: 30...2000, step: 10)
                            .tint(.orange)

                        // プリセットボタン
                        HStack(spacing: 8) {
                            ForEach([100, 180, 350, 500, 750], id: \.self) { preset in
                                Button("\(preset)ml") {
                                    amount = Double(preset)
                                }
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(amount == Double(preset) ? Color.orange : Color(.systemGray5))
                                .foregroundStyle(amount == Double(preset) ? .white : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                } header: {
                    Text("飲んだ量")
                }

                // アルコール度数
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("度数")
                            Spacer()
                            Text(String(format: "%.1f%%", alcoholPercentage))
                                .fontWeight(.semibold)
                        }

                        Slider(value: $alcoholPercentage, in: 0...60, step: 0.5)
                            .tint(.orange)

                        // プリセットボタン
                        HStack(spacing: 8) {
                            ForEach([0.0, 5.0, 12.0, 15.0, 25.0, 40.0], id: \.self) { preset in
                                Button("\(Int(preset))%") {
                                    alcoholPercentage = preset
                                }
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(alcoholPercentage == preset ? Color.orange : Color(.systemGray5))
                                .foregroundStyle(alcoholPercentage == preset ? .white : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                } header: {
                    Text("アルコール度数")
                }

                // 日時選択
                Section {
                    DatePicker("日時", selection: $dateTime)
                } header: {
                    Text("飲んだ日時")
                }

                // メモ
                Section {
                    TextField("メモ（任意）", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text("メモ")
                }

                // 純アルコール量の表示
                Section {
                    HStack {
                        Text("純アルコール量")
                        Spacer()
                        Text(String(format: "%.1f g", calculatedPureAlcohol))
                            .fontWeight(.bold)
                            .foregroundStyle(alcoholLevelColor)
                    }

                    HStack {
                        Text("ビール換算")
                        Spacer()
                        Text(String(format: "%.1f 本", calculatedPureAlcohol / 14.0))
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("計算結果")
                } footer: {
                    Text("純アルコール量(g) = 量(ml) × 度数(%) × 0.8")
                }
            }
            .navigationTitle("記録を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecord()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedDrinkType == nil)
                }
            }
            .sheet(isPresented: $showingDrinkPicker) {
                DrinkTypePickerView(selectedDrinkType: $selectedDrinkType) { drinkType in
                    // 選択時にデフォルト値をセット
                    amount = drinkType.defaultAmount
                    alcoholPercentage = drinkType.defaultAlcoholPercentage
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var calculatedPureAlcohol: Double {
        amount * (alcoholPercentage / 100) * 0.8
    }

    private var alcoholLevelColor: Color {
        if calculatedPureAlcohol <= 20 { return .green }
        if calculatedPureAlcohol <= 40 { return .orange }
        return .red
    }

    // MARK: - Actions
    private func saveRecord() {
        guard let drinkType = selectedDrinkType else { return }

        let record = DrinkRecord(
            drinkTypeName: drinkType.name,
            drinkTypeEmoji: drinkType.emoji,
            amount: amount,
            alcoholPercentage: alcoholPercentage,
            dateTime: dateTime,
            note: note.isEmpty ? nil : note
        )

        modelContext.insert(record)
        dismiss()
    }
}

// MARK: - Drink Type Picker View
struct DrinkTypePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDrinkType: DrinkType?
    var onSelect: (DrinkType) -> Void

    private let drinkTypes = DrinkType.defaultTypes
    private var categories: [String] {
        Array(Set(drinkTypes.map { $0.category })).sorted()
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(drinkTypes.filter { $0.category == category }) { drinkType in
                            Button(action: {
                                selectedDrinkType = drinkType
                                onSelect(drinkType)
                                dismiss()
                            }) {
                                HStack {
                                    Text(drinkType.emoji)
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text(drinkType.name)
                                            .foregroundStyle(.primary)
                                        Text("\(Int(drinkType.defaultAmount))ml / \(String(format: "%.1f", drinkType.defaultAlcoholPercentage))%")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if selectedDrinkType?.id == drinkType.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.orange)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("飲み物を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RecordInputView()
        .modelContainer(for: DrinkRecord.self, inMemory: true)
}
