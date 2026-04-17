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
    private var richLabel: TFYSwiftLabel!
    private var segmentedControl: NSSegmentedControl!
    private var searchField: NSSearchField!
    private var checkboxButton: NSButton!
    private var closureButton: NSButton!
    private var slider: NSSlider!
    private var sliderValueLabel: TFYSwiftLabel!
    private var datePicker: NSDatePicker!
    private var stepper: NSStepper!
    private var stepperValueLabel: TFYSwiftLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDemo()
    }

    // MARK: - Layout

    private func setupDemo() {
        let scroll = NSScrollView().chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .hasVerticalScroller(true)
            .hasHorizontalScroller(false)
            .autohidesScrollers(true)
            .build
        view.addSubview(scroll)

        // 必须使用 flipped 文档视图：默认 NSView 的 y 轴向上，而本页按「自上而下」递增 y 布局，
        // 否则首段标题会落在文档几何「底部」，滚动视窗初始只显示上方（实为末段日志），造成顶端内容「显示不全」。
        let content = DemoFlippedDocumentView(frame: .zero).chain
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        scroll.chain.documentView(content)

        // 文档高度必须用「等于内容总高度」的约束：若用 height >= scroll.height，
        // 引擎会取最小可行高度（通常等于可视区高度），手动改 frame 也会在下一轮 layout 被覆盖，导致无法纵向滚动。
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor),
        ])

        var y: CGFloat = 20

        let title = makeTitle("NSControl+Dejal 富文本扩展全功能演示")
        title.frame.origin = NSPoint(x: 20, y: y)
        content.addSubview(title)
        y += 36

        let subtitle = makeBody(
            "NSControl+Dejal 提供了在任意 NSControl 子类（NSTextField、NSButton 等）上直接操作富文本属性的能力，"
            + "支持按子串匹配修改、前后置图片插入、段落样式、文本装饰、特效、外观圆角/阴影、动画以及 NSButton / NSSegmentedControl / NSSearchField / NSSlider / NSDatePicker / NSStepper 扩展。",
            width: 760, height: 44
        )
        subtitle.frame.origin = NSPoint(x: 20, y: y)
        content.addSubview(subtitle)
        y += 56

        y = setupRichTextSubject(in: content, y: y)
        y = setupSpacingSection(in: content, y: y)
        y = setupParagraphSection(in: content, y: y)
        y = setupFontColorSection(in: content, y: y)
        y = setupDecorationSection(in: content, y: y)
        y = setupEffectSection(in: content, y: y)
        y = setupAdvancedSection(in: content, y: y)
        y = setupImageSection(in: content, y: y)
        y = setupAppearanceSection(in: content, y: y)
        y = setupAnimationSection(in: content, y: y)
        y = setupUtilitySection(in: content, y: y)
        y = setupButtonSection(in: content, y: y)
        y = setupSegmentedSection(in: content, y: y)
        y = setupSearchFieldSection(in: content, y: y)
        y = setupSliderSection(in: content, y: y)
        y = setupDatePickerSection(in: content, y: y)
        y = setupStepperSection(in: content, y: y)
        y = setupLogSection(in: content, y: y)

        let contentHeight = y + 24
        NSLayoutConstraint.activate([
            content.heightAnchor.constraint(equalToConstant: contentHeight),
        ])
        appendLog("NSControl+Dejal 演示页就绪，点击各按钮查看富文本效果。")
    }

    // MARK: - 0. Rich Text Subject

    private func setupRichTextSubject(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("演示文本载体")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 28

        richLabel = TFYSwiftLabel().chain
            .text("TFYSwiftMacOSAppKit 富文本演示：Swift 链式 API 让 macOS 开发更高效")
            .frame(NSRect(x: 20, y: cy, width: 720, height: 36))
            .font(.systemFont(ofSize: 18, weight: .medium))
            .textColor(.labelColor)
            .maximumNumberOfLines(0)
            .lineBreakMode(.byWordWrapping)
            .wraps(true)
            .drawsBackground(false)
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

    // MARK: - 1. Spacing

    private func setupSpacingSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("1. 字间距 / 行间距 / 行高倍数 / 对齐")
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

    // MARK: - 2. Paragraph Style (New)

    private func setupParagraphSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("2. 段落样式（行高 / 缩进 / 换行 / 连字符）")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "changeMinimumLineHeight · changeMaximumLineHeight · changeFixedLineHeight · changeFirstLineHeadIndent · changeHeadIndent · changeTailIndent · changeLineBreakMode · changeHyphenationFactor",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 26

        let items: [(String, Selector)] = [
            ("最小行高 24", #selector(applyMinLineHeight)),
            ("最大行高 30", #selector(applyMaxLineHeight)),
            ("固定行高 28", #selector(applyFixedLineHeight)),
            ("首行缩进 30", #selector(applyFirstLineIndent)),
            ("整体头部缩进 20", #selector(applyHeadIndent)),
            ("尾部缩进 -40", #selector(applyTailIndent)),
            ("换行:截断尾部", #selector(applyLineBreakTruncate)),
            ("换行:按字换行", #selector(applyLineBreakByChar)),
            ("连字符因子 1.0", #selector(applyHyphenation)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 3. Font & Color

    private func setupFontColorSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("3. 字体与颜色")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "changeFonts · changeFontSize · changeFontWeight · changeColors · changeBackgroundColor — 支持数组模式，对不同子串分别设置不同字体/颜色/大小/粗细。",
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
            ("changeFontSize 22", #selector(applyFontSizeOnly)),
            ("「Swift」字号 24", #selector(applyFontSizePartial)),
            ("changeFontWeight .bold", #selector(applyFontWeightBold)),
            ("「API」粗细 .heavy", #selector(applyFontWeightPartial)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 4. Decoration

    private func setupDecorationSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("4. 文本装饰（下划线 / 删除线 / 连字）")
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

    // MARK: - 5. Effects

    private func setupEffectSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("5. 文本特效（描边 / 阴影）")
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

    // MARK: - 6. Advanced

    private func setupAdvancedSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("6. 高级文本属性")
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

    // MARK: - 7. Inline Images

    private func setupImageSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("7. 前后置图片插入")
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

    // MARK: - 8. Appearance

    private func setupAppearanceSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("8. 外观（圆角边框 / 阴影 / 占位符）")
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

    // MARK: - 9. Animation

    private func setupAnimationSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("9. 动画效果")
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

    // MARK: - 10. NSControl Utility (New)

    private func setupUtilitySection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("10. NSControl 实用工具")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "setEnabled(animated:) · sizeToFit(withPadding:) · setTooltip · applyAttributeConfigurations — 控件级便捷操作。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 26

        let items: [(String, Selector)] = [
            ("禁用(动画)", #selector(applyDisableAnimated)),
            ("启用(动画)", #selector(applyEnableAnimated)),
            ("sizeToFit+内边距", #selector(applySizeToFitPadding)),
            ("设置 Tooltip", #selector(applyTooltip)),
            ("applyAttributeConfigs", #selector(applyMultiAttrConfigs)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 11. NSButton Extension

    private func setupButtonSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("11. NSButton 扩展")
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

    // MARK: - 12. NSSegmentedControl Extension

    private func setupSegmentedSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("12. NSSegmentedControl 扩展")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "segmentTitles · setSegmentTitles · deselectAllSegments · selectNextSegment · selectPreviousSegment · setSegmentImages · setUniformSegmentWidth · setSegmentEnabled · setSegmentToolTip",
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
        cy += 34

        let items: [(String, Selector)] = [
            ("selectNext", #selector(segmentNext)),
            ("selectPrevious", #selector(segmentPrevious)),
            ("deselectAll", #selector(segmentDeselectAll)),
            ("读取标题", #selector(readSegmentTitles)),
            ("更换标题", #selector(changeSegmentTitles)),
            ("设置图标", #selector(segmentSetImages)),
            ("统一宽度 80", #selector(segmentUniformWidth)),
            ("禁用第2段", #selector(segmentDisableSecond)),
            ("启用第2段", #selector(segmentEnableSecond)),
            ("设置ToolTip", #selector(segmentSetToolTip)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 13. NSSearchField Extension

    private func setupSearchFieldSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("13. NSSearchField 扩展")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "trimmedSearchText · clearSearch · setRecentSearches · limitRecentSearches · addRecentSearch — 搜索框增强。",
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
        cy += 34

        let items: [(String, Selector)] = [
            ("trimmedSearchText", #selector(searchTrimmed)),
            ("clearSearch", #selector(searchClear)),
            ("setRecentSearches", #selector(searchSetRecent)),
            ("limitRecentSearches(3)", #selector(searchLimitRecent)),
            ("addRecentSearch", #selector(searchAddRecent)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 14. NSSlider Extension (New)

    private func setupSliderSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("14. NSSlider 扩展")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "normalizedValue · setValue(animated:) · resetToMinimum/Maximum/Center · increment/decrement · configure(min:max:current:)",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 28

        slider = NSSlider().chain
            .frame(NSRect(x: 20, y: cy, width: 300, height: 26))
            .build
        slider.configure(min: 0, max: 100, current: 50)
        slider.target = self
        slider.action = #selector(sliderValueChanged)
        c.addSubview(slider)

        sliderValueLabel = TFYSwiftLabel().chain
            .text("值: 50.0 | 归一化: 0.50")
            .frame(NSRect(x: 340, y: cy, width: 250, height: 22))
            .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
            .textColor(.secondaryLabelColor)
            .drawsBackground(false)
            .build
        c.addSubview(sliderValueLabel)
        cy += 34

        let items: [(String, Selector)] = [
            ("resetToMinimum", #selector(sliderResetMin)),
            ("resetToMaximum", #selector(sliderResetMax)),
            ("resetToCenter", #selector(sliderResetCenter)),
            ("increment +10", #selector(sliderIncrement)),
            ("decrement -10", #selector(sliderDecrement)),
            ("setValue(75,动画)", #selector(sliderSetAnimated)),
            ("normalizedValue=0.3", #selector(sliderSetNormalized)),
            ("configure(0~200,80)", #selector(sliderReconfigure)),
            ("读取 normalizedValue", #selector(sliderReadNormalized)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 15. NSDatePicker Extension (New)

    private func setupDatePickerSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("15. NSDatePicker 扩展")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "setDateRange(from:to:) · resetToNow · isDateInRange — 日期选择器增强。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 28

        datePicker = NSDatePicker().chain
            .frame(NSRect(x: 20, y: cy, width: 260, height: 26))
            .build
        datePicker.datePickerStyle = .textFieldAndStepper
        datePicker.datePickerElements = [.yearMonthDay, .hourMinute]
        datePicker.dateValue = Date()
        c.addSubview(datePicker)
        cy += 34

        let items: [(String, Selector)] = [
            ("resetToNow", #selector(datePickerResetNow)),
            ("setDateRange(本月)", #selector(datePickerSetRange)),
            ("isDateInRange?", #selector(datePickerCheckRange)),
            ("清除日期范围", #selector(datePickerClearRange)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 16. NSStepper Extension (New)

    private func setupStepperSection(in c: NSView, y: CGFloat) -> CGFloat {
        var cy = y

        let header = makeSection("16. NSStepper 扩展")
        header.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(header)
        cy += 26

        let desc = makeBody(
            "configure(min:max:increment:current:) · resetToMinimum — 步进器增强。",
            width: 760, height: 22
        )
        desc.frame.origin = NSPoint(x: 20, y: cy)
        c.addSubview(desc)
        cy += 28

        stepper = NSStepper().chain
            .frame(NSRect(x: 20, y: cy, width: 40, height: 26))
            .build
        stepper.configure(min: 0, max: 20, increment: 2, current: 10)
        stepper.target = self
        stepper.action = #selector(stepperValueChanged)
        c.addSubview(stepper)

        stepperValueLabel = TFYSwiftLabel().chain
            .text("步进器值: 10.0 (范围: 0~20, 步进: 2)")
            .frame(NSRect(x: 70, y: cy, width: 350, height: 22))
            .font(.monospacedSystemFont(ofSize: 12, weight: .regular))
            .textColor(.secondaryLabelColor)
            .drawsBackground(false)
            .build
        c.addSubview(stepperValueLabel)
        cy += 34

        let items: [(String, Selector)] = [
            ("resetToMinimum", #selector(stepperResetMin)),
            ("configure(0~50,5,25)", #selector(stepperReconfigure)),
            ("读取当前值", #selector(stepperReadValue)),
        ]
        cy = layoutButtonGrid(items, in: c, y: cy)
        return cy + 8
    }

    // MARK: - 17. Log

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

    // MARK: - Actions: Spacing

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

    // MARK: - Actions: Paragraph Style (New)

    @objc private func applyMinLineHeight() {
        richLabel.changeMinimumLineHeight(with: 24)
        appendLog("changeMinimumLineHeight(with: 24)")
    }

    @objc private func applyMaxLineHeight() {
        richLabel.changeMaximumLineHeight(with: 30)
        appendLog("changeMaximumLineHeight(with: 30)")
    }

    @objc private func applyFixedLineHeight() {
        richLabel.changeFixedLineHeight(with: 28)
        appendLog("changeFixedLineHeight(with: 28) — 同时设置最小和最大行高为 28")
    }

    @objc private func applyFirstLineIndent() {
        richLabel.changeFirstLineHeadIndent(with: 30)
        appendLog("changeFirstLineHeadIndent(with: 30) — 首行缩进 30pt")
    }

    @objc private func applyHeadIndent() {
        richLabel.changeHeadIndent(with: 20)
        appendLog("changeHeadIndent(with: 20) — 整体头部缩进 20pt")
    }

    @objc private func applyTailIndent() {
        richLabel.changeTailIndent(with: -40)
        appendLog("changeTailIndent(with: -40) — 右侧内缩 40pt（负值）")
    }

    @objc private func applyLineBreakTruncate() {
        richLabel.changeLineBreakMode(with: .byTruncatingTail)
        appendLog("changeLineBreakMode(with: .byTruncatingTail)")
    }

    @objc private func applyLineBreakByChar() {
        richLabel.changeLineBreakMode(with: .byCharWrapping)
        appendLog("changeLineBreakMode(with: .byCharWrapping)")
    }

    @objc private func applyHyphenation() {
        richLabel.changeHyphenationFactor(with: 1.0)
        appendLog("changeHyphenationFactor(with: 1.0) — 完全启用连字符")
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

    @objc private func applyFontSizeOnly() {
        richLabel.changeFontSize(to: 22)
        appendLog("changeFontSize(to: 22) — 仅修改字号，保持字体族不变")
    }

    @objc private func applyFontSizePartial() {
        richLabel.changeFontSize(to: 24, changeText: "Swift")
        appendLog("changeFontSize(to: 24, changeText: \"Swift\") — 仅「Swift」字号 24")
    }

    @objc private func applyFontWeightBold() {
        richLabel.changeFontWeight(to: .bold)
        appendLog("changeFontWeight(to: .bold) — 全局字重变粗")
    }

    @objc private func applyFontWeightPartial() {
        richLabel.changeFontWeight(to: .heavy, changeText: "API")
        appendLog("changeFontWeight(to: .heavy, changeText: \"API\") — 仅「API」加重")
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

    // MARK: - Actions: NSControl Utility (New)

    @objc private func applyDisableAnimated() {
        richLabel.setEnabled(false, animated: true, duration: 0.3)
        appendLog("setEnabled(false, animated: true) — 透明度渐变到 0.4 后禁用")
    }

    @objc private func applyEnableAnimated() {
        richLabel.setEnabled(true, animated: true, duration: 0.3)
        appendLog("setEnabled(true, animated: true) — 透明度渐变到 1.0 后启用")
    }

    @objc private func applySizeToFitPadding() {
        richLabel.sizeToFit(withPadding: NSEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        appendLog("sizeToFit(withPadding: top:8 left:16 bottom:8 right:16) — frame: \(richLabel.frame)")
    }

    @objc private func applyTooltip() {
        richLabel.setTooltip("这是由 setTooltip 设置的工具提示文本")
        appendLog("setTooltip(\"...\") — 鼠标悬停查看效果")
    }

    @objc private func applyMultiAttrConfigs() {
        richLabel.applyAttributeConfigurations([
            (text: "Swift", attributes: [.foregroundColor: NSColor.systemRed, .font: NSFont.boldSystemFont(ofSize: 20)]),
            (text: "API", attributes: [.foregroundColor: NSColor.systemBlue, .underlineStyle: NSUnderlineStyle.single.rawValue]),
            (text: "macOS", attributes: [.foregroundColor: NSColor.systemGreen, .backgroundColor: NSColor.systemYellow.withAlphaComponent(0.3)]),
        ])
        appendLog("applyAttributeConfigurations — 批量对 Swift/API/macOS 应用不同属性")
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

    @objc private func segmentPrevious() {
        segmentedControl.selectPreviousSegment(wrapping: true)
        appendLog("selectPreviousSegment → selected: \(segmentedControl.selectedSegment)")
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

    @objc private func segmentSetImages() {
        let names = ["swift", "terminal.fill", "cpu.fill", "memorychip.fill"]
        let images = names.compactMap { NSImage(systemSymbolName: $0, accessibilityDescription: nil) }
        segmentedControl.setSegmentImages(images)
        appendLog("setSegmentImages — 为前 \(images.count) 个分段设置 SF Symbol 图标")
    }

    @objc private func segmentUniformWidth() {
        segmentedControl.setUniformSegmentWidth(80)
        appendLog("setUniformSegmentWidth(80) — 所有分段统一 80pt 宽")
    }

    @objc private func segmentDisableSecond() {
        segmentedControl.setSegmentEnabled(false, forSegment: 1)
        appendLog("setSegmentEnabled(false, forSegment: 1) — 禁用第 2 个分段")
    }

    @objc private func segmentEnableSecond() {
        segmentedControl.setSegmentEnabled(true, forSegment: 1)
        appendLog("setSegmentEnabled(true, forSegment: 1) — 启用第 2 个分段")
    }

    @objc private func segmentSetToolTip() {
        for i in 0..<segmentedControl.segmentCount {
            let title = segmentedControl.label(forSegment: i) ?? "Segment \(i)"
            segmentedControl.setSegmentToolTip("提示: \(title)", forSegment: i)
        }
        appendLog("setSegmentToolTip — 为所有分段设置 ToolTip，悬停查看")
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
        searchField.setRecentSearches(["SwiftUI", "AppKit", "Combine", "async/await", "Concurrency"])
        appendLog("setRecentSearches([SwiftUI, AppKit, Combine, async/await, Concurrency])")
    }

    @objc private func searchLimitRecent() {
        searchField.limitRecentSearches(to: 3)
        appendLog("limitRecentSearches(to: 3) — 限制最多 3 条记录，当前: \(searchField.recentSearches)")
    }

    @objc private func searchAddRecent() {
        let text = searchField.trimmedSearchText.isEmpty ? "TFYSwift Demo" : searchField.trimmedSearchText
        searchField.addRecentSearch(text)
        appendLog("addRecentSearch(\"\(text)\") — 自动去重并置顶，当前: \(searchField.recentSearches)")
    }

    // MARK: - Actions: NSSlider (New)

    @objc private func sliderValueChanged() {
        updateSliderLabel()
    }

    @objc private func sliderResetMin() {
        slider.resetToMinimum()
        updateSliderLabel()
        appendLog("resetToMinimum → \(slider.doubleValue)")
    }

    @objc private func sliderResetMax() {
        slider.resetToMaximum()
        updateSliderLabel()
        appendLog("resetToMaximum → \(slider.doubleValue)")
    }

    @objc private func sliderResetCenter() {
        slider.resetToCenter()
        updateSliderLabel()
        appendLog("resetToCenter → \(slider.doubleValue)")
    }

    @objc private func sliderIncrement() {
        slider.increment(by: 10)
        updateSliderLabel()
        appendLog("increment(by: 10) → \(slider.doubleValue)")
    }

    @objc private func sliderDecrement() {
        slider.decrement(by: 10)
        updateSliderLabel()
        appendLog("decrement(by: 10) → \(slider.doubleValue)")
    }

    @objc private func sliderSetAnimated() {
        slider.setValue(75, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updateSliderLabel()
        }
        appendLog("setValue(75, animated: true)")
    }

    @objc private func sliderSetNormalized() {
        slider.normalizedValue = 0.3
        updateSliderLabel()
        appendLog("normalizedValue = 0.3 → doubleValue: \(String(format: "%.1f", slider.doubleValue))")
    }

    @objc private func sliderReconfigure() {
        slider.configure(min: 0, max: 200, current: 80)
        updateSliderLabel()
        appendLog("configure(min: 0, max: 200, current: 80)")
    }

    @objc private func sliderReadNormalized() {
        appendLog("normalizedValue: \(String(format: "%.4f", slider.normalizedValue)) (doubleValue: \(String(format: "%.1f", slider.doubleValue)), range: \(slider.minValue)~\(slider.maxValue))")
    }

    private func updateSliderLabel() {
        sliderValueLabel.stringValue = "值: \(String(format: "%.1f", slider.doubleValue)) | 归一化: \(String(format: "%.2f", slider.normalizedValue))"
    }

    // MARK: - Actions: NSDatePicker (New)

    @objc private func datePickerResetNow() {
        datePicker.resetToNow()
        appendLog("resetToNow → \(datePicker.dateValue)")
    }

    @objc private func datePickerSetRange() {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        datePicker.setDateRange(from: startOfMonth, to: endOfMonth)
        appendLog("setDateRange — 本月范围: \(formatDate(startOfMonth)) ~ \(formatDate(endOfMonth))")
    }

    @objc private func datePickerCheckRange() {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        let inRange = datePicker.isDateInRange(from: startOfMonth, to: endOfMonth)
        appendLog("isDateInRange(本月) → \(inRange)，当前选择: \(formatDate(datePicker.dateValue))")
    }

    @objc private func datePickerClearRange() {
        datePicker.setDateRange(from: nil, to: nil)
        appendLog("setDateRange(nil, nil) — 清除日期范围限制")
    }

    // MARK: - Actions: NSStepper (New)

    @objc private func stepperValueChanged() {
        updateStepperLabel()
    }

    @objc private func stepperResetMin() {
        stepper.resetToMinimum()
        updateStepperLabel()
        appendLog("resetToMinimum → \(stepper.doubleValue)")
    }

    @objc private func stepperReconfigure() {
        stepper.configure(min: 0, max: 50, increment: 5, current: 25)
        updateStepperLabel()
        appendLog("configure(min: 0, max: 50, increment: 5, current: 25)")
    }

    @objc private func stepperReadValue() {
        appendLog("stepper.doubleValue: \(stepper.doubleValue), range: \(stepper.minValue)~\(stepper.maxValue), increment: \(stepper.increment)")
    }

    private func updateStepperLabel() {
        stepperValueLabel.stringValue = "步进器值: \(String(format: "%.1f", stepper.doubleValue)) (范围: \(Int(stepper.minValue))~\(Int(stepper.maxValue)), 步进: \(Int(stepper.increment)))"
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
        richLabel.alphaValue = 1.0
        richLabel.isEnabled = true
        richLabel.toolTip = nil
        richLabel.layer?.shadowOpacity = 0
        richLabel.setRoundedBorder(cornerRadius: 8, borderWidth: 0, borderColor: .clear)
        richLabel.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        appendLog("文本已重新载入（包括恢复透明度、启用状态、tooltip）")
    }

    @objc private func measureTextSize() {
        let size = richLabel.textSize(maxSize: NSSize(width: 720, height: CGFloat.greatestFiniteMagnitude))
        appendLog("textSize: \(Int(size.width)) x \(Int(size.height)) pt")
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
        let line = "\u{2022} \(message)\n"
        logTextView?.string += line
        logTextView?.scrollToEndOfDocument(nil)
    }

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
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

    private func makeTitle(_ text: String) -> TFYSwiftLabel {
        TFYSwiftLabel().chain
            .text(text)
            .font(.boldSystemFont(ofSize: 22))
            .textColor(.labelColor)
            .drawsBackground(false)
            .frame(NSRect(x: 0, y: 0, width: 500, height: 28))
            .build
    }

    private func makeSection(_ text: String) -> TFYSwiftLabel {
        TFYSwiftLabel().chain
            .text(text)
            .font(.systemFont(ofSize: 15, weight: .semibold))
            .textColor(.labelColor)
            .drawsBackground(false)
            .frame(NSRect(x: 0, y: 0, width: 500, height: 22))
            .build
    }

    private func makeBody(_ text: String, width: CGFloat, height: CGFloat) -> TFYSwiftLabel {
        TFYSwiftLabel().chain
            .text(text)
            .font(.systemFont(ofSize: 12))
            .textColor(.secondaryLabelColor)
            .maximumNumberOfLines(0)
            .lineBreakMode(.byWordWrapping)
            .wraps(true)
            .drawsBackground(false)
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
