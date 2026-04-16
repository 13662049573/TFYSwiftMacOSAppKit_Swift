//
//  ControlDemoViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by Codex on 2026/4/16.
//

import Cocoa

final class ControlDemoViewController: NSViewController {

    private var logTextView: NSTextView!

    // Demonstration subjects
    private var richLabel: NSTextField!
    private var segmentedControl: NSSegmentedControl!
    private var searchField: NSSearchField!
    private var checkboxButton: NSButton!
    private var closureButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDemo()
    }

    // MARK: - Layout

    private func setupDemo() {
        let scroll = NSScrollView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .hasVerticalScroller(true)
            .autohidesScrollers(true)
            .build
        view.addSubview(scroll)

        let content = NSView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        scroll.chain.documentView(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor),
        ])

        var y: CGFloat = 20

        let title = makeTitle("NSControl+Dejal 富文本扩展全功能演示")
        title.frame.origin = NSPoint(x: 20, y: y)
        content.addSubview(title)
        y += 36

        let subtitle = makeBody(
            "NSControl+Dejal 提供了在任意 NSControl 子类（NSTextField、NSButton 等）上直接操作富文本属性的能力，"
            + "支持按子串匹配修改、前后置图片插入、段落样式、文本装饰、特效、外观圆角/阴影、动画以及 NSButton / NSSegmentedControl / NSSearchField 扩展。",
            width: 760, height: 44
        )
        subtitle.frame.origin = NSPoint(x: 20, y: y)
        content.addSubview(subtitle)
        y += 56

        y = setupRichTextSubject(in: content, y: y)
        y = setupSpacingSection(in: content, y: y)
        y = setupFontColorSection(in: content, y: y)
        y = setupDecorationSection(in: content, y: y)
        y = setupEffectSection(in: content, y: y)
        y = setupAdvancedSection(in: content, y: y)
        y = setupImageSection(in: content, y: y)
        y = setupAppearanceSection(in: content, y: y)
        y = setupAnimationSection(in: content, y: y)
        y = setupButtonSection(in: content, y: y)
        y = setupSegmentedSection(in: content, y: y)
        y = setupSearchFieldSection(in: content, y: y)
        y = setupLogSection(in: content, y: y)

        content.frame.size.height = y + 24
        appendLog("NSControl+Dejal 演示页就绪，点击各按钮查看富文本效果。")
    }

    // MARK: - 0. Rich Text Subject

    private func setupRichTextSubject(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("演示文本载体")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 28

        richLabel = NSTextField(labelWithString: "TFYSwiftMacOSAppKit 富文本演示：Swift 链式 API 让 macOS 开发更高效").chain
            .frame(NSRect(x: 20, y: cy, width: 720, height: 36))
            .font(.systemFont(ofSize: 18, weight: .medium))
            .textColor(.labelColor)
            .maximumNumberOfLines(0)
            .lineBreakMode(.byWordWrapping)
            .wraps(true)
            .build
        richLabel.wantsLayer = true
        richLabel.layer?.cornerRadius = 8
        richLabel.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        c.addSubview(richLabel)
        cy += 44

        let resetBtn = makeBtn("重置富文本", action: #selector(resetRichText))
        resetBtn.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(resetBtn)

        let reloadBtn = makeBtn("重新载入文本", action: #selector(reloadRichText))
        reloadBtn.frame.origin = NSPoint(x: 130, y: cy)
        c.addSubview(reloadBtn)

        let sizeBtn = makeBtn("测量文本尺寸", action: #selector(measureTextSize))
        sizeBtn.frame.origin = NSPoint(x: 260, y: cy)
        c.addSubview(sizeBtn)

        let clearBtn = makeBtn("清空文本", action: #selector(clearRichText))
        clearBtn.frame.origin = NSPoint(x: 390, y: cy)
        c.addSubview(clearBtn)

        let trimBtn = makeBtn("trimmedStringValue", action: #selector(showTrimmed))
        trimBtn.frame.origin = NSPoint(x: 500, y: cy)
        c.addSubview(trimBtn)

        return cy + 40
    }

    // MARK: - 1. Spacing & Paragraph

    private func setupSpacingSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("1. 字间距 / 行间距 / 段落样式")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "changeSpace · changeLineSpace · changeParagraphSpacing · changeParagraphSpacingBefore · changeLineHeightMultiple · changeTextAlignment — 可全局或按子串匹配应用。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 26

        let items: [(String, Selector)] = [
            ("字间距 +4", #selector(applyKerning)),
            ("字间距「Swift」+8", #selector(applyKerningPartial)),
            ("行间距 6", #selector(applyLineSpacing)),
            ("段后间距 10", #selector(applyParagraphSpacing)),
            ("段前间距 8", #selector(applyParagraphSpacingBefore)),
            ("行高倍数 1.5", #selector(applyLineHeight)),
            ("居中对齐", #selector(applyCenter)),
            ("右对齐", #selector(applyRight)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 2. Font & Color

    private func setupFontColorSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("2. 字体与颜色")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "changeFonts · changeColors · changeBackgroundColor — 支持数组模式，对不同子串分别设置不同字体/颜色。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 26

        let items: [(String, Selector)] = [
            ("全局粗体 16pt", #selector(applyFontGlobal)),
            ("「富文本」大号红色", #selector(applyFontPartial)),
            ("多子串多颜色", #selector(applyMultiColor)),
            ("「链式」背景高亮", #selector(applyBgColor)),
            ("setAttributedText", #selector(applySetAttributedText)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 3. Decoration

    private func setupDecorationSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("3. 文本装饰（下划线 / 删除线 / 连字）")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "changeUnderlineStyle · changeUnderlineColor · changeStrikethroughStyle · changeStrikethroughColor · changeLigature — 按子串精准应用。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 26

        let items: [(String, Selector)] = [
            ("全局下划线", #selector(applyUnderlineGlobal)),
            ("「macOS」双下划线蓝色", #selector(applyUnderlinePartial)),
            ("「演示」删除线", #selector(applyStrikethrough)),
            ("删除线红色", #selector(applyStrikethroughColor)),
            ("连字 on/off", #selector(applyLigature)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 4. Effects

    private func setupEffectSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("4. 文本特效（描边 / 阴影）")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "changeStrokeColor · changeStrokeWidth · changeShadow · changeTextEffect — 可以给特定子串添加描边或阴影。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 26

        let items: [(String, Selector)] = [
            ("「API」描边蓝色", #selector(applyStroke)),
            ("全局阴影", #selector(applyShadow)),
            ("「Swift」描边+阴影", #selector(applyStrokeAndShadow)),
            ("letterpress 效果", #selector(applyLetterpress)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 5. Advanced

    private func setupAdvancedSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("5. 高级文本属性")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "changeBaselineOffset · changeObliqueness · changeExpansions · changeWritingDirection · changeKern · removeAttributes — 精细控制排版。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 26

        let items: [(String, Selector)] = [
            ("基线偏移「Swift」+5", #selector(applyBaseline)),
            ("倾斜「链式」0.3", #selector(applyObliqueness)),
            ("扩展「API」0.5", #selector(applyExpansion)),
            ("CTKern +6", #selector(applyCTKern)),
            ("移除下划线属性", #selector(removeUnderline)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 6. Inline Images

    private func setupImageSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("6. 前后置图片插入")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "setText(prefixImages:suffixImages:imageSpan:) · changeText(frontImages:) — 在文本前后自动插入内联图标，自动对齐基线。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 26

        let items: [(String, Selector)] = [
            ("前置图标", #selector(applyPrefixImage)),
            ("后置图标", #selector(applySuffixImage)),
            ("前后都有", #selector(applyBothImages)),
            ("多图 + 间距 8", #selector(applyMultiImages)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 7. Appearance

    private func setupAppearanceSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("7. 外观（圆角边框 / 阴影 / 占位符）")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "setRoundedBorder · setShadow · setPlaceholder — 在 NSControl 层级设置 Layer 圆角、阴影和占位符文本。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 26

        let items: [(String, Selector)] = [
            ("圆角 12 + 蓝边框", #selector(applyRoundedBorder)),
            ("图层阴影", #selector(applyLayerShadow)),
            ("移除圆角和阴影", #selector(removeAppearance)),
            ("设置占位符", #selector(applyPlaceholder)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 8. Animation

    private func setupAnimationSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("8. 动画效果")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "animateAlpha · addFadeAnimation — 对 NSControl 做透明度动画和淡入淡出。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 26

        let items: [(String, Selector)] = [
            ("淡出到 0.2", #selector(animFadeOut)),
            ("恢复到 1.0", #selector(animFadeIn)),
            ("淡入淡出", #selector(animFadeInOut)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 9. NSButton Extension

    private func setupButtonSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("9. NSButton 扩展")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "onAction 闭包 · isOn / toggleState · configure(title:image:) · makeCheckbox — 简化按钮操作。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 28

        closureButton = NSButton().chain
            .frame(NSRect(x: 20, y: cy, width: 160, height: 30))
            .title("闭包按钮（点我）")
            .font(.systemFont(ofSize: 12, weight: .medium))
            .bezelStyle(.rounded)
            .build
        closureButton.onAction { [weak self] btn in
            self?.appendLog("onAction 闭包触发，当前标题: \(btn.title)")
        }
        c.addSubview(closureButton)

        checkboxButton = NSButton.makeCheckbox(title: "复选框 (makeCheckbox)", checked: false)
        checkboxButton.frame = NSRect(x: 200, y: cy + 4, width: 200, height: 20)
        checkboxButton.onAction { [weak self] btn in
            self?.appendLog("Checkbox isOn: \(btn.isOn)")
        }
        c.addSubview(checkboxButton)

        let toggleBtn = makeBtn("toggleState", action: #selector(toggleCheckbox))
        toggleBtn.frame.origin = NSPoint(x: 420, y: cy)
        c.addSubview(toggleBtn)

        let configBtn = makeBtn("configure(图标)", action: #selector(configureButtonWithImage))
        configBtn.frame.origin = NSPoint(x: 540, y: cy)
        c.addSubview(configBtn)

        return cy + 42
    }

    // MARK: - 10. NSSegmentedControl Extension

    private func setupSegmentedSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("10. NSSegmentedControl 扩展")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "segmentTitles · setSegmentTitles · deselectAllSegments · selectNextSegment — 快捷操作分段控件。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 28

        segmentedControl = NSSegmentedControl().chain
            .frame(NSRect(x: 20, y: cy, width: 300, height: 26))
            .build
        segmentedControl.setSegmentTitles(["Swift", "Objective-C", "Rust", "Go"])
        segmentedControl.selectedSegment = 0
        c.addSubview(segmentedControl)

        let nextBtn = makeBtn("selectNext", action: #selector(segmentNext))
        nextBtn.frame.origin = NSPoint(x: 340, y: cy - 2)
        c.addSubview(nextBtn)

        let deselectBtn = makeBtn("deselectAll", action: #selector(segmentDeselectAll))
        deselectBtn.frame.origin = NSPoint(x: 440, y: cy - 2)
        c.addSubview(deselectBtn)

        let titlesBtn = makeBtn("读取标题", action: #selector(readSegmentTitles))
        titlesBtn.frame.origin = NSPoint(x: 550, y: cy - 2)
        c.addSubview(titlesBtn)

        let setBtn = makeBtn("更换标题", action: #selector(changeSegmentTitles))
        setBtn.frame.origin = NSPoint(x: 650, y: cy - 2)
        c.addSubview(setBtn)

        return cy + 38
    }

    // MARK: - 11. NSSearchField Extension

    private func setupSearchFieldSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("11. NSSearchField 扩展")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "trimmedSearchText · clearSearch · setRecentSearches — 搜索框增强。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 28

        searchField = NSSearchField().chain
            .frame(NSRect(x: 20, y: cy, width: 280, height: 26))
            .build
        searchField.placeholderString = "输入搜索内容..."
        c.addSubview(searchField)

        let trimBtn = makeBtn("trimmedSearchText", action: #selector(searchTrimmed))
        trimBtn.frame.origin = NSPoint(x: 320, y: cy - 2)
        c.addSubview(trimBtn)

        let clearBtn = makeBtn("clearSearch", action: #selector(searchClear))
        clearBtn.frame.origin = NSPoint(x: 470, y: cy - 2)
        c.addSubview(clearBtn)

        let recentBtn = makeBtn("setRecentSearches", action: #selector(searchSetRecent))
        recentBtn.frame.origin = NSPoint(x: 570, y: cy - 2)
        c.addSubview(recentBtn)

        return cy + 38
    }

    // MARK: - 12. Log

    private func setupLogSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("操作日志")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)

        let clearBtn = makeBtn("清空", action: #selector(clearLog))
        clearBtn.frame.origin = NSPoint(x: 700, y: cy - 2)
        c.addSubview(clearBtn)
        cy += 30

        let logScroll = NSScrollView().chain
            .frame(NSRect(x: 20, y: cy, width: 750, height: 180))
            .hasVerticalScroller(true)
            .borderType(.bezelBorder)
            .autohidesScrollers(true)
            .build
        c.addSubview(logScroll)

        logTextView = NSTextView().chain
            .frame(NSRect(x: 0, y: 0, width: 750, height: 180))
            .editable(false)
            .font(.monospacedSystemFont(ofSize: 11, weight: .regular))
            .backgroundColor(.textBackgroundColor)
            .textColor(.labelColor)
            .wraps(true)
            .string("")
            .build
        logScroll.chain.documentView(logTextView)

        return cy + 200
    }

    // MARK: - Actions: Spacing & Paragraph

    @objc private func applyKerning() {
        richLabel.changeSpace(with: 4)
        appendLog("changeSpace(with: 4) — 全局字间距 +4")
    }

    @objc private func applyKerningPartial() {
        richLabel.changeSpace(with: 8, changeText: "Swift")
        appendLog("changeSpace(with: 8, changeText: \"Swift\") — 仅「Swift」字间距 +8")
    }

    @objc private func applyLineSpacing() {
        richLabel.changeLineSpace(with: 6)
        appendLog("changeLineSpace(with: 6)")
    }

    @objc private func applyParagraphSpacing() {
        richLabel.changeParagraphSpacing(with: 10)
        appendLog("changeParagraphSpacing(with: 10)")
    }

    @objc private func applyParagraphSpacingBefore() {
        richLabel.changeParagraphSpacingBefore(with: 8)
        appendLog("changeParagraphSpacingBefore(with: 8)")
    }

    @objc private func applyLineHeight() {
        richLabel.changeLineHeightMultiple(with: 1.5)
        appendLog("changeLineHeightMultiple(with: 1.5)")
    }

    @objc private func applyCenter() {
        richLabel.changeTextAlignment(with: .center)
        appendLog("changeTextAlignment(with: .center)")
    }

    @objc private func applyRight() {
        richLabel.changeTextAlignment(with: .right)
        appendLog("changeTextAlignment(with: .right)")
    }

    // MARK: - Actions: Font & Color

    @objc private func applyFontGlobal() {
        richLabel.changeFonts(with: [.boldSystemFont(ofSize: 16)])
        appendLog("changeFonts(with: [.boldSystemFont(ofSize: 16)])")
    }

    @objc private func applyFontPartial() {
        richLabel.changeFonts(with: [.boldSystemFont(ofSize: 22)], changeTexts: ["富文本"])
        richLabel.changeColors(with: [.systemRed], changeTexts: ["富文本"])
        appendLog("changeFonts + changeColors 仅作用于「富文本」")
    }

    @objc private func applyMultiColor() {
        richLabel.changeColors(with: [.systemBlue, .systemOrange, .systemPurple], changeTexts: ["Swift", "链式", "macOS"])
        appendLog("changeColors 多子串多颜色: Swift=蓝, 链式=橙, macOS=紫")
    }

    @objc private func applyBgColor() {
        richLabel.changeBackgroundColor(with: .systemYellow.withAlphaComponent(0.4), changeText: "链式")
        appendLog("changeBackgroundColor(with: .systemYellow, changeText: \"链式\")")
    }

    @objc private func applySetAttributedText() {
        richLabel.setAttributedText(
            "通过 setAttributedText 一次性设置字体+颜色+对齐",
            font: .systemFont(ofSize: 15, weight: .semibold),
            color: .systemTeal,
            alignment: .center
        )
        appendLog("setAttributedText(text, font, color, alignment)")
    }

    // MARK: - Actions: Decoration

    @objc private func applyUnderlineGlobal() {
        richLabel.changeUnderlineStyle(with: .single)
        richLabel.changeUnderlineColor(with: .systemBlue)
        appendLog("changeUnderlineStyle(.single) + changeUnderlineColor(.systemBlue)")
    }

    @objc private func applyUnderlinePartial() {
        richLabel.changeUnderlineStyle(with: NSNumber(value: NSUnderlineStyle.double.rawValue), changeText: "macOS")
        richLabel.changeUnderlineColor(with: .systemBlue, changeText: "macOS")
        appendLog("changeUnderlineStyle(.double) + Color 仅「macOS」")
    }

    @objc private func applyStrikethrough() {
        richLabel.changeStrikethroughStyle(with: .single, changeText: "演示")
        appendLog("changeStrikethroughStyle(.single, changeText: \"演示\")")
    }

    @objc private func applyStrikethroughColor() {
        richLabel.changeStrikethroughStyle(with: .single)
        richLabel.changeStrikethroughColor(with: .systemRed)
        appendLog("全局删除线 + 红色")
    }

    @objc private func applyLigature() {
        richLabel.changeLigature(enabled: true)
        appendLog("changeLigature(enabled: true)")
    }

    // MARK: - Actions: Effects

    @objc private func applyStroke() {
        richLabel.changeStrokeColor(with: .systemBlue, changeText: "API")
        richLabel.changeStrokeWidth(with: NSNumber(value: 2.0), changeText: "API")
        appendLog("changeStrokeColor(.systemBlue) + changeStrokeWidth(2.0) 仅「API」")
    }

    @objc private func applyShadow() {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 4
        shadow.shadowOffset = NSSize(width: 2, height: -2)
        shadow.shadowColor = NSColor.systemPurple.withAlphaComponent(0.6)
        richLabel.changeShadow(with: shadow)
        appendLog("changeShadow — 全局紫色阴影")
    }

    @objc private func applyStrokeAndShadow() {
        richLabel.changeStrokeColor(with: .systemOrange, changeText: "Swift")
        richLabel.changeStrokeWidth(with: NSNumber(value: -3.0), changeText: "Swift")
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = NSSize(width: 1, height: -1)
        shadow.shadowColor = NSColor.systemOrange.withAlphaComponent(0.5)
        richLabel.changeShadow(with: shadow, changeText: "Swift")
        appendLog("「Swift」描边(-3=填充+描边) + 阴影")
    }

    @objc private func applyLetterpress() {
        richLabel.changeTextEffect(with: NSAttributedString.TextEffectStyle.letterpressStyle.rawValue)
        appendLog("changeTextEffect(letterpressStyle)")
    }

    // MARK: - Actions: Advanced

    @objc private func applyBaseline() {
        richLabel.changeBaselineOffset(with: NSNumber(value: 5.0), changeText: "Swift")
        appendLog("changeBaselineOffset(5.0, \"Swift\") — 基线上移")
    }

    @objc private func applyObliqueness() {
        richLabel.changeObliqueness(with: NSNumber(value: 0.3), changeText: "链式")
        appendLog("changeObliqueness(0.3, \"链式\") — 倾斜")
    }

    @objc private func applyExpansion() {
        richLabel.changeExpansions(with: NSNumber(value: 0.5), changeText: "API")
        appendLog("changeExpansions(0.5, \"API\") — 横向扩展")
    }

    @objc private func applyCTKern() {
        richLabel.changeCTKern(with: NSNumber(value: 6.0))
        appendLog("changeCTKern(6.0) — CoreText 全局字距")
    }

    @objc private func removeUnderline() {
        richLabel.removeAttributes([.underlineStyle, .underlineColor])
        appendLog("removeAttributes([.underlineStyle, .underlineColor])")
    }

    // MARK: - Actions: Images

    @objc private func applyPrefixImage() {
        let img = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil) ?? NSImage()
        richLabel.setText("前置图标文本演示", prefixImages: [img], imageSpan: 4)
        appendLog("setText(prefixImages: [star.fill])")
    }

    @objc private func applySuffixImage() {
        let img = NSImage(systemSymbolName: "arrow.right.circle.fill", accessibilityDescription: nil) ?? NSImage()
        richLabel.setText("后置图标文本演示", suffixImages: [img], imageSpan: 4)
        appendLog("setText(suffixImages: [arrow.right.circle.fill])")
    }

    @objc private func applyBothImages() {
        let prefix = NSImage(systemSymbolName: "bolt.fill", accessibilityDescription: nil) ?? NSImage()
        let suffix = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: nil) ?? NSImage()
        richLabel.setText("前后都有图标", prefixImages: [prefix], suffixImages: [suffix], imageSpan: 6)
        appendLog("setText(prefixImages + suffixImages)")
    }

    @objc private func applyMultiImages() {
        let imgs: [NSImage] = ["star.fill", "heart.fill", "flame.fill"].compactMap {
            NSImage(systemSymbolName: $0, accessibilityDescription: nil)
        }
        richLabel.setText("多图标排列", prefixImages: imgs, imageSpan: 8)
        appendLog("setText(prefixImages: 3 icons, imageSpan: 8)")
    }

    // MARK: - Actions: Appearance

    @objc private func applyRoundedBorder() {
        richLabel.setRoundedBorder(cornerRadius: 12, borderWidth: 2, borderColor: .systemBlue)
        appendLog("setRoundedBorder(12, 2, .systemBlue)")
    }

    @objc private func applyLayerShadow() {
        richLabel.setShadow(shadowColor: .systemIndigo, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 8, shadowOpacity: 0.35)
        appendLog("setShadow(.systemIndigo, offset(0,4), radius 8, opacity 0.35)")
    }

    @objc private func removeAppearance() {
        richLabel.setRoundedBorder(cornerRadius: 0, borderWidth: 0, borderColor: .clear)
        richLabel.layer?.shadowOpacity = 0
        appendLog("已移除圆角和阴影")
    }

    @objc private func applyPlaceholder() {
        richLabel.setPlaceholder("这是 NSControl 层级的占位符", color: .systemGray)
        appendLog("setPlaceholder — 对 NSTextField 设置富文本占位符")
    }

    // MARK: - Actions: Animation

    @objc private func animFadeOut() {
        richLabel.animateAlpha(to: 0.2, duration: 0.5)
        appendLog("animateAlpha(to: 0.2)")
    }

    @objc private func animFadeIn() {
        richLabel.animateAlpha(to: 1.0, duration: 0.5)
        appendLog("animateAlpha(to: 1.0)")
    }

    @objc private func animFadeInOut() {
        richLabel.addFadeAnimation(duration: 0.4)
        appendLog("addFadeAnimation(0.4) — 淡出再淡入")
    }

    // MARK: - Actions: NSButton

    @objc private func toggleCheckbox() {
        checkboxButton.toggleState()
        appendLog("toggleState → isOn: \(checkboxButton.isOn)")
    }

    @objc private func configureButtonWithImage() {
        let img = NSImage(systemSymbolName: "bolt.fill", accessibilityDescription: nil)
        closureButton.configure(title: "带图标按钮", image: img, imagePosition: .imageLeading)
        appendLog("configure(title:image:imagePosition:)")
    }

    // MARK: - Actions: NSSegmentedControl

    @objc private func segmentNext() {
        segmentedControl.selectNextSegment(wrapping: true)
        appendLog("selectNextSegment → selected: \(segmentedControl.selectedSegment)")
    }

    @objc private func segmentDeselectAll() {
        segmentedControl.deselectAllSegments()
        appendLog("deselectAllSegments")
    }

    @objc private func readSegmentTitles() {
        appendLog("segmentTitles: \(segmentedControl.segmentTitles)")
    }

    @objc private func changeSegmentTitles() {
        segmentedControl.setSegmentTitles(["macOS", "iOS", "watchOS", "tvOS", "visionOS"])
        segmentedControl.selectedSegment = 0
        appendLog("setSegmentTitles([macOS, iOS, watchOS, tvOS, visionOS])")
    }

    // MARK: - Actions: NSSearchField

    @objc private func searchTrimmed() {
        appendLog("trimmedSearchText: \"\(searchField.trimmedSearchText)\"")
    }

    @objc private func searchClear() {
        searchField.clearSearch()
        appendLog("clearSearch()")
    }

    @objc private func searchSetRecent() {
        searchField.setRecentSearches(["SwiftUI", "AppKit", "Combine", "async/await"])
        appendLog("setRecentSearches([SwiftUI, AppKit, Combine, async/await])")
    }

    // MARK: - Actions: Rich Text Subject

    @objc private func resetRichText() {
        richLabel.resetTextAttributes()
        appendLog("resetTextAttributes — 仅保留纯文本")
    }

    @objc private func reloadRichText() {
        richLabel.stringValue = "TFYSwiftMacOSAppKit 富文本演示：Swift 链式 API 让 macOS 开发更高效"
        richLabel.font = .systemFont(ofSize: 18, weight: .medium)
        richLabel.textColor = .labelColor
        richLabel.layer?.shadowOpacity = 0
        richLabel.setRoundedBorder(cornerRadius: 8, borderWidth: 0, borderColor: .clear)
        richLabel.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        appendLog("文本已重新载入")
    }

    @objc private func measureTextSize() {
        let size = richLabel.textSize(maxSize: NSSize(width: 720, height: CGFloat.greatestFiniteMagnitude))
        appendLog("textSize: \(Int(size.width)) × \(Int(size.height)) pt")
    }

    @objc private func clearRichText() {
        richLabel.clearText()
        appendLog("clearText()")
    }

    @objc private func showTrimmed() {
        appendLog("trimmedStringValue: \"\(richLabel.trimmedStringValue)\"")
        appendLog("isEmptyOrWhitespace: \(richLabel.isEmptyOrWhitespace)")
    }

    @objc private func clearLog() {
        logTextView.string = ""
    }

    // MARK: - Helpers

    private func appendLog(_ message: String) {
        let line = "• \(message)\n"
        logTextView?.string += line
        logTextView?.scrollToEndOfDocument(nil)
    }

    private func layoutButtonGrid(_ items: [(String, Selector)], in c: NSView, y: CGFloat) -> CGFloat {
        var x: CGFloat = 20
        var cy = y
        let maxX: CGFloat = 760
        for (title, action) in items {
            let w = max(CGFloat(title.count) * 11 + 20, 100)
            if x + w > maxX {
                x = 20
                cy += 36
            }
            let btn = makeBtn(title, action: action)
            btn.frame = NSRect(x: x, y: cy, width: w, height: 28)
            c.addSubview(btn)
            x += w + 8
        }
        return cy + 36
    }

    private func makeTitle(_ text: String) -> NSTextField {
        NSTextField(labelWithString: text).chain
            .font(.boldSystemFont(ofSize: 22))
            .textColor(.labelColor)
            .frame(NSRect(x: 0, y: 0, width: 500, height: 28))
            .build
    }

    private func makeSection(_ text: String) -> NSTextField {
        NSTextField(labelWithString: text).chain
            .font(.systemFont(ofSize: 15, weight: .semibold))
            .textColor(.labelColor)
            .frame(NSRect(x: 0, y: 0, width: 500, height: 22))
            .build
    }

    private func makeBody(_ text: String, width: CGFloat, height: CGFloat) -> NSTextField {
        NSTextField(labelWithString: text).chain
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .maximumNumberOfLines(0)
            .lineBreakMode(.byWordWrapping)
            .wraps(true)
            .frame(NSRect(x: 0, y: 0, width: width, height: height))
            .build
    }

    private func makeBtn(_ title: String, action: Selector) -> NSButton {
        NSButton().chain
            .frame(NSRect(x: 0, y: 0, width: 100, height: 28))
            .title(title)
            .font(.systemFont(ofSize: 12, weight: .medium))
            .bezelStyle(.rounded)
            .addTarget(self, action: action)
            .build
    }
}
