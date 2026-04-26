import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel

    init(settingsStore: UserSettingsStore) {
        _viewModel = State(initialValue: SettingsViewModel(settingsStore: settingsStore))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    header
                    statusCard
                    personalCard
                    waterGoalCard
                    reminderCard
                    toneCard
                    resetButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
                .frame(maxWidth: 620)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("设置")
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("提醒偏好")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.ink)

                Text("把称呼、目标和提醒节奏调成她会喜欢的样子。")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppColors.lilac)
                .accessibilityHidden(true)
        }
    }

    private var statusCard: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.isReminderEnabled ? "bell.badge.fill" : "bell.slash.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(viewModel.isReminderEnabled ? AppColors.waterBlue : AppColors.secondaryInk)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.reminderStatusText)
                    .font(.headline)
                    .foregroundStyle(AppColors.ink)

                Text(viewModel.statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryInk)
            }

            Spacer()
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.7), lineWidth: 1)
        }
    }

    private var personalCard: some View {
        settingsCard(title: "私人称呼", icon: "heart.text.square.fill", color: AppColors.softPink) {
            TextField("她的昵称", text: nicknameBinding)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }

    private var waterGoalCard: some View {
        settingsCard(title: "喝水目标", icon: "drop.fill", color: AppColors.waterBlue) {
            Stepper(value: dailyTargetBinding, in: 800...3000, step: 100) {
                settingValueRow(title: "每日目标", value: viewModel.targetAmountText)
            }

            Divider()

            Stepper(value: defaultDrinkBinding, in: 50...600, step: 50) {
                settingValueRow(title: "默认每次", value: viewModel.defaultDrinkAmountText)
            }
        }
    }

    private var reminderCard: some View {
        settingsCard(title: "提醒时间", icon: "bell.badge.fill", color: AppColors.lilac) {
            Toggle("开启喝水提醒", isOn: reminderEnabledBinding)
                .font(.subheadline.weight(.semibold))

            Divider()

            DatePicker("开始时间", selection: reminderStartBinding, displayedComponents: .hourAndMinute)
                .font(.subheadline.weight(.semibold))

            DatePicker("结束时间", selection: reminderEndBinding, displayedComponents: .hourAndMinute)
                .font(.subheadline.weight(.semibold))

            Divider()

            Picker("提醒间隔", selection: reminderIntervalBinding) {
                ForEach(viewModel.reminderIntervalOptions, id: \.self) { minutes in
                    Text(intervalLabel(for: minutes)).tag(minutes)
                }
            }
            .font(.subheadline.weight(.semibold))
        }
    }

    private var toneCard: some View {
        settingsCard(title: "通知语气", icon: "text.bubble.fill", color: AppColors.softPink) {
            Picker("语气模式", selection: notificationToneBinding) {
                ForEach(NotificationTone.allCases) { tone in
                    Text(tone.displayName).tag(tone)
                }
            }
            .pickerStyle(.menu)

            Text(viewModel.notificationTone.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.secondaryInk)
        }
    }

    private var resetButton: some View {
        Button {
            withAnimation(.snappy) {
                viewModel.resetToDefaults()
            }
        } label: {
            Label("恢复默认设置", systemImage: "arrow.counterclockwise")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.bordered)
        .tint(AppColors.softPink)
    }

    private func settingsCard<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(color)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppColors.ink)
            }

            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.7), lineWidth: 1)
        }
    }

    private func settingValueRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.ink)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppColors.waterBlue)
                .monospacedDigit()
        }
    }

    private func intervalLabel(for minutes: Int) -> String {
        minutes < 60 ? "\(minutes) 分钟" : "\(minutes / 60) 小时"
    }

    private var nicknameBinding: Binding<String> {
        Binding(
            get: { viewModel.nickname },
            set: { viewModel.updateNickname($0) }
        )
    }

    private var dailyTargetBinding: Binding<Int> {
        Binding(
            get: { viewModel.dailyTargetAmountML },
            set: { viewModel.updateDailyTargetAmount($0) }
        )
    }

    private var defaultDrinkBinding: Binding<Int> {
        Binding(
            get: { viewModel.defaultDrinkAmountML },
            set: { viewModel.updateDefaultDrinkAmount($0) }
        )
    }

    private var reminderStartBinding: Binding<Date> {
        Binding(
            get: { viewModel.reminderStartDate },
            set: { viewModel.updateReminderStartDate($0) }
        )
    }

    private var reminderEndBinding: Binding<Date> {
        Binding(
            get: { viewModel.reminderEndDate },
            set: { viewModel.updateReminderEndDate($0) }
        )
    }

    private var reminderIntervalBinding: Binding<Int> {
        Binding(
            get: { viewModel.reminderIntervalMinutes },
            set: { viewModel.updateReminderIntervalMinutes($0) }
        )
    }

    private var reminderEnabledBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isReminderEnabled },
            set: { viewModel.updateReminderEnabled($0) }
        )
    }

    private var notificationToneBinding: Binding<NotificationTone> {
        Binding(
            get: { viewModel.notificationTone },
            set: { viewModel.updateNotificationTone($0) }
        )
    }
}

#Preview {
    NavigationStack {
        SettingsView(settingsStore: UserSettingsStore.preview)
    }
}
