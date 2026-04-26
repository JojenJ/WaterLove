import Foundation

enum NotificationScenario: String, CaseIterable, Identifiable {
    case normal
    case morning
    case afternoon
    case evening
    case lowProgress
    case goalAlmostDone
    case goalCompleted
    case gentleReminder
    case clingy
    case gentlePush
    case achievement
    case missedCheck
    case eveningWrapUp
    case personal

    var id: String { rawValue }
}

struct NotificationMessage {
    let title: String
    let body: String
}

struct NotificationMessageProvider {
    func randomMessage(
        nickname: String,
        tone: NotificationTone,
        scenario: NotificationScenario,
        progress: Double
    ) -> String {
        let template = selectedTemplate(tone: tone, scenario: scenario)
        return render(template.body, nickname: nickname, progress: progress)
    }

    func randomNotification(
        nickname: String,
        tone: NotificationTone,
        scenario: NotificationScenario,
        progress: Double
    ) -> NotificationMessage {
        NotificationMessage(
            title: title(nickname: nickname, scenario: scenario),
            body: randomMessage(
                nickname: nickname,
                tone: tone,
                scenario: scenario,
                progress: progress
            )
        )
    }

    private func title(nickname: String, scenario: NotificationScenario) -> String {
        switch scenario {
        case .morning:
            return "早安补水时间"
        case .evening, .eveningWrapUp:
            return "晚间温柔收尾"
        case .goalAlmostDone:
            return "快达标了"
        case .goalCompleted, .achievement:
            return "今日水分达标"
        case .missedCheck:
            return "我有点担心你"
        case .personal:
            return "\(nickname) 的专属提醒"
        case .gentlePush:
            return "喝水进度提醒"
        default:
            return "WaterLove 喝水提醒"
        }
    }

    private func selectedTemplate(
        tone: NotificationTone,
        scenario: NotificationScenario
    ) -> MessageTemplate {
        let exactMatches = Self.templates.filter { $0.tone == tone && $0.scenario == scenario }
        if let exact = exactMatches.randomElement() {
            return exact
        }

        let scenarioMatches = Self.templates.filter { $0.scenario == scenario }
        if let scenarioMatch = scenarioMatches.randomElement() {
            return scenarioMatch
        }

        let toneMatches = Self.templates.filter { $0.tone == tone }
        if let toneMatch = toneMatches.randomElement() {
            return toneMatch
        }

        return Self.templates.randomElement() ?? MessageTemplate(
            tone: .caring,
            scenario: .normal,
            body: "{{nickname}}，喝一口水吧，我在认真提醒你。"
        )
    }

    private func render(_ template: String, nickname: String, progress: Double) -> String {
        let safeNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? UserSettings.default.nickname
            : nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let percentText = "\(Int((min(max(progress, 0), 1) * 100).rounded()))%"

        return template
            .replacingOccurrences(of: "{{nickname}}", with: safeNickname)
            .replacingOccurrences(of: "{{progress}}", with: percentText)
    }
}

private struct MessageTemplate {
    let tone: NotificationTone
    let scenario: NotificationScenario
    let body: String
}

private extension NotificationMessageProvider {
    static let templates: [MessageTemplate] = [
        .init(tone: .sweet, scenario: .gentleReminder, body: "{{nickname}}，喝一小口水吧，今天也要被好好照顾。"),
        .init(tone: .sweet, scenario: .morning, body: "早上第一杯水准备好了吗，{{nickname}}？身体会悄悄感谢你。"),
        .init(tone: .sweet, scenario: .afternoon, body: "下午有点忙也没关系，先喝一口水，把自己接住。"),
        .init(tone: .sweet, scenario: .eveningWrapUp, body: "{{nickname}}，晚间补水收尾啦，别让今天差在最后几口。"),
        .init(tone: .sweet, scenario: .lowProgress, body: "今日进度 {{progress}}，不着急，我们从这一口慢慢追上来。"),
        .init(tone: .sweet, scenario: .goalAlmostDone, body: "离目标只差一点点，{{nickname}} 再喝几口就很漂亮。"),
        .init(tone: .sweet, scenario: .goalCompleted, body: "今日水分达标，{{nickname}} 超棒，奖励自己一个轻松呼吸。"),
        .init(tone: .sweet, scenario: .clingy, body: "我轻轻戳一下：{{nickname}}，可以喝水啦。"),
        .init(tone: .sweet, scenario: .missedCheck, body: "有一会儿没看到喝水记录了，{{nickname}}，我有点小担心。"),
        .init(tone: .sweet, scenario: .personal, body: "专属提醒送达：{{nickname}}，现在适合喝一口水。"),

        .init(tone: .playful, scenario: .normal, body: "{{nickname}} 的水分余额不足，请立刻充值一口。"),
        .init(tone: .playful, scenario: .morning, body: "早安，今日第一口水任务刷新。{{nickname}} 请查收。"),
        .init(tone: .playful, scenario: .afternoon, body: "下午场开启，先喝水再继续当闪闪发光的人。"),
        .init(tone: .playful, scenario: .evening, body: "夜间补水小窗口打开，错过我会明天继续念叨。"),
        .init(tone: .playful, scenario: .lowProgress, body: "进度 {{progress}}，水杯可能在等你主动一点。"),
        .init(tone: .playful, scenario: .goalAlmostDone, body: "快满格了，{{nickname}}，现在喝一口就很有仪式感。"),
        .init(tone: .playful, scenario: .achievement, body: "达标徽章已点亮，今天的 {{nickname}} 很会照顾自己。"),
        .init(tone: .playful, scenario: .clingy, body: "喝一口水吧，就一口，我不催第二遍……大概。"),
        .init(tone: .playful, scenario: .missedCheck, body: "系统检测到水杯有点寂寞，{{nickname}} 要不要理它一下？"),
        .init(tone: .playful, scenario: .personal, body: "{{nickname}} 专属喝水铃声在脑内响起：叮，喝水。"),

        .init(tone: .gentlePush, scenario: .gentlePush, body: "{{nickname}}，该喝水了。先别滑走，喝完再继续。"),
        .init(tone: .gentlePush, scenario: .morning, body: "早上的水别欠账，{{nickname}}，现在喝最省心。"),
        .init(tone: .gentlePush, scenario: .afternoon, body: "下午容易忘，水杯现在需要你配合一下。"),
        .init(tone: .gentlePush, scenario: .evening, body: "晚间最后几次提醒之一，{{nickname}}，别把水留到睡前一口闷。"),
        .init(tone: .gentlePush, scenario: .lowProgress, body: "进度 {{progress}} 偏低，先喝 200ml，把节奏拉回来。"),
        .init(tone: .gentlePush, scenario: .goalAlmostDone, body: "目标就在前面，{{nickname}}，补完这一点就收工。"),
        .init(tone: .gentlePush, scenario: .goalCompleted, body: "目标完成，今天不催了，但明天我还会准时出现。"),
        .init(tone: .gentlePush, scenario: .missedCheck, body: "已经隔了一阵没记录了，{{nickname}}，现在喝一口比较稳。"),
        .init(tone: .gentlePush, scenario: .eveningWrapUp, body: "收尾提醒：别拖到太晚，睡前猛喝水不划算。"),
        .init(tone: .gentlePush, scenario: .personal, body: "{{nickname}}，这是专属催促：水杯拿起来。"),

        .init(tone: .caring, scenario: .gentleReminder, body: "{{nickname}}，如果现在方便，喝一口水，让身体缓一缓。"),
        .init(tone: .caring, scenario: .morning, body: "早上先补点水，今天会舒服很多。"),
        .init(tone: .caring, scenario: .afternoon, body: "忙到现在辛苦了，{{nickname}}，喝口水再继续。"),
        .init(tone: .caring, scenario: .evening, body: "晚上慢慢收尾，少量多次补一点水就好。"),
        .init(tone: .caring, scenario: .lowProgress, body: "今天进度 {{progress}}，别有压力，先从眼前这一口开始。"),
        .init(tone: .caring, scenario: .goalAlmostDone, body: "快完成了，{{nickname}}，再补一点就可以安心收工。"),
        .init(tone: .caring, scenario: .goalCompleted, body: "今日目标完成，照顾自己的这件小事做得很好。"),
        .init(tone: .caring, scenario: .missedCheck, body: "我注意到你可能有点久没喝水了，先照顾一下自己。"),
        .init(tone: .caring, scenario: .eveningWrapUp, body: "{{nickname}}，今晚别太晚补水，温柔收个尾就好。"),
        .init(tone: .caring, scenario: .personal, body: "给 {{nickname}} 的提醒：你不用完美，但要记得喝水。"),

        .init(tone: .sweet, scenario: .achievement, body: "{{nickname}} 又完成一小步，今天的自己值得被夸。"),
        .init(tone: .playful, scenario: .gentlePush, body: "水杯已经举手发言：请 {{nickname}} 关注我。"),
        .init(tone: .gentlePush, scenario: .normal, body: "现在喝一口，别等口渴了才补救。"),
        .init(tone: .caring, scenario: .normal, body: "喝点水吧，{{nickname}}，给身体一点安静的照顾。"),
        .init(tone: .sweet, scenario: .normal, body: "{{nickname}}，水杯在旁边的话，就顺手喝一口。"),
        .init(tone: .playful, scenario: .eveningWrapUp, body: "今日补水尾声，{{nickname}} 再来一点就可以打烊。"),
        .init(tone: .gentlePush, scenario: .achievement, body: "完成进度值得表扬，但下一杯也要记得安排。"),
        .init(tone: .caring, scenario: .achievement, body: "每一次记录都算数，{{nickname}} 今天做得很认真。")
    ]
}
