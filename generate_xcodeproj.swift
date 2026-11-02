#!/usr/bin/env swift
//  generate_xcodeproj.swift
//  Generates a minimal BatteryPercentage.xcodeproj for the iOS host app
//  and WidgetKit extension.  Run:  swift generate_xcodeproj.swift
//
//  This avoids a dependency on XcodeGen / Tuist / CocoaPods.

import Foundation

let projectDir = "BatteryPercentage.xcodeproj"
let pbxproj    = "\(projectDir)/project.pbxproj"

// ── UUIDs (deterministic so re-runs produce the same project) ──

let rootObject               = "AA000000000000000000AA01"
let mainGroup                = "AA000000000000000000AA02"
let appGroup                 = "AA000000000000000000AA03"
let widgetGroup              = "AA000000000000000000AA04"
let productsGroup            = "AA000000000000000000AA05"

let appTarget                = "AA000000000000000000BB01"
let widgetTarget             = "AA000000000000000000BB02"

let appProductRef            = "AA000000000000000000CC01"
let widgetProductRef         = "AA000000000000000000CC02"

let appSources               = "AA000000000000000000DD01"
let widgetSources            = "AA000000000000000000DD02"
let appFrameworks            = "AA000000000000000000DD03"
let widgetFrameworks         = "AA000000000000000000DD04"
let embedExtensions          = "AA000000000000000000DD05"

let appSourceFile1           = "AA000000000000000000EE01"
let appSourceFile2           = "AA000000000000000000EE02"
let widgetSourceFile1        = "AA000000000000000000EE03"

let appSourceRef1            = "AA000000000000000000FF01"
let appSourceRef2            = "AA000000000000000000FF02"
let widgetSourceRef1         = "AA000000000000000000FF03"

let appInfoRef               = "AA000000000000000000FF04"
let widgetInfoRef            = "AA000000000000000000FF05"

let appConfigList            = "AA000000000000000000AB01"
let appDebugConfig           = "AA000000000000000000AB02"
let appReleaseConfig         = "AA000000000000000000AB03"
let widgetConfigList         = "AA000000000000000000AB04"
let widgetDebugConfig        = "AA000000000000000000AB05"
let widgetReleaseConfig      = "AA000000000000000000AB06"
let projectConfigList        = "AA000000000000000000AB07"
let projectDebugConfig       = "AA000000000000000000AB08"
let projectReleaseConfig     = "AA000000000000000000AB09"

let widgetProductInApp       = "AA000000000000000000AC01"
let widgetContainerProxy     = "AA000000000000000000AC02"
let appDependency            = "AA000000000000000000AC03"

let content = """
// !$*UTF8*$!
{
    archiveVersion = 1;
    classes = { };
    objectVersion = 56;
    objects = {

/* ── File References ─────────────────────────── */

        \(appSourceRef1) = {
            isa = PBXFileReference;
            lastKnownFileType = sourcecode.swift;
            name = BatteryPercentageApp.swift;
            path = iOS/App/BatteryPercentageApp.swift;
            sourceTree = "<group>";
        };
        \(appSourceRef2) = {
            isa = PBXFileReference;
            lastKnownFileType = sourcecode.swift;
            name = ContentView.swift;
            path = iOS/App/ContentView.swift;
            sourceTree = "<group>";
        };
        \(widgetSourceRef1) = {
            isa = PBXFileReference;
            lastKnownFileType = sourcecode.swift;
            name = BatteryWidget.swift;
            path = iOS/Widget/BatteryWidget.swift;
            sourceTree = "<group>";
        };
        \(appInfoRef) = {
            isa = PBXFileReference;
            lastKnownFileType = text.plist.xml;
            name = Info.plist;
            path = iOS/App/Info.plist;
            sourceTree = "<group>";
        };
        \(widgetInfoRef) = {
            isa = PBXFileReference;
            lastKnownFileType = text.plist.xml;
            name = Info.plist;
            path = iOS/Widget/Info.plist;
            sourceTree = "<group>";
        };
        \(appProductRef) = {
            isa = PBXFileReference;
            explicitFileType = wrapper.application;
            includeInIndex = 0;
            name = BatteryPercentage.app;
            path = BatteryPercentage.app;
            sourceTree = BUILT_PRODUCTS_DIR;
        };
        \(widgetProductRef) = {
            isa = PBXFileReference;
            explicitFileType = "wrapper.app-extension";
            includeInIndex = 0;
            name = BatteryWidgetExtension.appex;
            path = BatteryWidgetExtension.appex;
            sourceTree = BUILT_PRODUCTS_DIR;
        };

/* ── Groups ──────────────────────────────────── */

        \(mainGroup) = {
            isa = PBXGroup;
            children = ( \(appGroup), \(widgetGroup), \(productsGroup) );
            sourceTree = "<group>";
        };
        \(appGroup) = {
            isa = PBXGroup;
            children = ( \(appSourceRef1), \(appSourceRef2), \(appInfoRef) );
            name = App;
            sourceTree = "<group>";
        };
        \(widgetGroup) = {
            isa = PBXGroup;
            children = ( \(widgetSourceRef1), \(widgetInfoRef) );
            name = Widget;
            sourceTree = "<group>";
        };
        \(productsGroup) = {
            isa = PBXGroup;
            children = ( \(appProductRef), \(widgetProductRef) );
            name = Products;
            sourceTree = "<group>";
        };

/* ── Build Files ─────────────────────────────── */

        \(appSourceFile1) = {
            isa = PBXBuildFile;
            fileRef = \(appSourceRef1);
        };
        \(appSourceFile2) = {
            isa = PBXBuildFile;
            fileRef = \(appSourceRef2);
        };
        \(widgetSourceFile1) = {
            isa = PBXBuildFile;
            fileRef = \(widgetSourceRef1);
        };
        \(widgetProductInApp) = {
            isa = PBXBuildFile;
            fileRef = \(widgetProductRef);
            settings = { ATTRIBUTES = (RemoveHeadersOnCopy, ); };
        };

/* ── Build Phases ────────────────────────────── */

        \(appSources) = {
            isa = PBXSourcesBuildPhase;
            buildActionMask = 2147483647;
            files = ( \(appSourceFile1), \(appSourceFile2) );
            runOnlyForDeploymentPostprocessing = 0;
        };
        \(widgetSources) = {
            isa = PBXSourcesBuildPhase;
            buildActionMask = 2147483647;
            files = ( \(widgetSourceFile1) );
            runOnlyForDeploymentPostprocessing = 0;
        };
        \(appFrameworks) = {
            isa = PBXFrameworksBuildPhase;
            buildActionMask = 2147483647;
            files = ( );
            runOnlyForDeploymentPostprocessing = 0;
        };
        \(widgetFrameworks) = {
            isa = PBXFrameworksBuildPhase;
            buildActionMask = 2147483647;
            files = ( );
            runOnlyForDeploymentPostprocessing = 0;
        };
        \(embedExtensions) = {
            isa = PBXCopyFilesBuildPhase;
            buildActionMask = 2147483647;
            dstPath = "";
            dstSubfolderSpec = 13;
            files = ( \(widgetProductInApp) );
            name = "Embed Extensions";
            runOnlyForDeploymentPostprocessing = 0;
        };

/* ── Container Item Proxy & Dependency ───────── */

        \(widgetContainerProxy) = {
            isa = PBXContainerItemProxy;
            containerPortal = \(rootObject);
            proxyType = 1;
            remoteGlobalIDString = \(widgetTarget);
            remoteInfo = BatteryWidgetExtension;
        };
        \(appDependency) = {
            isa = PBXTargetDependency;
            target = \(widgetTarget);
            targetProxy = \(widgetContainerProxy);
        };

/* ── Targets ─────────────────────────────────── */

        \(appTarget) = {
            isa = PBXNativeTarget;
            buildConfigurationList = \(appConfigList);
            buildPhases = ( \(appSources), \(appFrameworks), \(embedExtensions) );
            buildRules = ( );
            dependencies = ( \(appDependency) );
            name = BatteryPercentage;
            productName = BatteryPercentage;
            productReference = \(appProductRef);
            productType = "com.apple.product-type.application";
        };
        \(widgetTarget) = {
            isa = PBXNativeTarget;
            buildConfigurationList = \(widgetConfigList);
            buildPhases = ( \(widgetSources), \(widgetFrameworks) );
            buildRules = ( );
            dependencies = ( );
            name = BatteryWidgetExtension;
            productName = BatteryWidgetExtension;
            productReference = \(widgetProductRef);
            productType = "com.apple.product-type.app-extension";
        };

/* ── Build Configurations ────────────────────── */

        \(projectDebugConfig) = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ALWAYS_SEARCH_USER_PATHS = NO;
                CLANG_ENABLE_MODULES = YES;
                COPY_PHASE_STRIP = NO;
                DEBUG_INFORMATION_FORMAT = dwarf;
                ENABLE_STRICT_OBJC_MSGSEND = YES;
                GCC_OPTIMIZATION_LEVEL = 0;
                IPHONEOS_DEPLOYMENT_TARGET = 17.0;
                MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
                ONLY_ACTIVE_ARCH = YES;
                SDKROOT = iphoneos;
                SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
                SWIFT_OPTIMIZATION_LEVEL = "-Onone";
                SWIFT_VERSION = 5.0;
            };
            name = Debug;
        };
        \(projectReleaseConfig) = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ALWAYS_SEARCH_USER_PATHS = NO;
                CLANG_ENABLE_MODULES = YES;
                COPY_PHASE_STRIP = YES;
                DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
                ENABLE_NS_ASSERTIONS = NO;
                ENABLE_STRICT_OBJC_MSGSEND = YES;
                IPHONEOS_DEPLOYMENT_TARGET = 17.0;
                SDKROOT = iphoneos;
                SWIFT_COMPILATION_MODE = wholemodule;
                SWIFT_OPTIMIZATION_LEVEL = "-O";
                SWIFT_VERSION = 5.0;
                VALIDATE_PRODUCT = YES;
            };
            name = Release;
        };
        \(appDebugConfig) = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                GENERATE_INFOPLIST_FILE = NO;
                INFOPLIST_FILE = iOS/App/Info.plist;
                INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
                INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
                INFOPLIST_KEY_UILaunchScreen_Generation = YES;
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                MARKETING_VERSION = 1.0.0;
                PRODUCT_BUNDLE_IDENTIFIER = com.batterypercent.app;
                PRODUCT_NAME = "$(TARGET_NAME)";
                SWIFT_EMIT_LOC_STRINGS = YES;
                TARGETED_DEVICE_FAMILY = "1,2";
            };
            name = Debug;
        };
        \(appReleaseConfig) = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                GENERATE_INFOPLIST_FILE = NO;
                INFOPLIST_FILE = iOS/App/Info.plist;
                INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
                INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
                INFOPLIST_KEY_UILaunchScreen_Generation = YES;
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                MARKETING_VERSION = 1.0.0;
                PRODUCT_BUNDLE_IDENTIFIER = com.batterypercent.app;
                PRODUCT_NAME = "$(TARGET_NAME)";
                SWIFT_EMIT_LOC_STRINGS = YES;
                TARGETED_DEVICE_FAMILY = "1,2";
            };
            name = Release;
        };
        \(widgetDebugConfig) = {
            isa = XCBuildConfiguration;
            buildSettings = {
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                GENERATE_INFOPLIST_FILE = NO;
                INFOPLIST_FILE = iOS/Widget/Info.plist;
                MARKETING_VERSION = 1.0.0;
                PRODUCT_BUNDLE_IDENTIFIER = com.batterypercent.app.widget;
                PRODUCT_NAME = "$(TARGET_NAME)";
                SKIP_INSTALL = YES;
                SWIFT_EMIT_LOC_STRINGS = YES;
                TARGETED_DEVICE_FAMILY = "1,2";
            };
            name = Debug;
        };
        \(widgetReleaseConfig) = {
            isa = XCBuildConfiguration;
            buildSettings = {
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                GENERATE_INFOPLIST_FILE = NO;
                INFOPLIST_FILE = iOS/Widget/Info.plist;
                MARKETING_VERSION = 1.0.0;
                PRODUCT_BUNDLE_IDENTIFIER = com.batterypercent.app.widget;
                PRODUCT_NAME = "$(TARGET_NAME)";
                SKIP_INSTALL = YES;
                SWIFT_EMIT_LOC_STRINGS = YES;
                TARGETED_DEVICE_FAMILY = "1,2";
            };
            name = Release;
        };

/* ── Config Lists ────────────────────────────── */

        \(projectConfigList) = {
            isa = XCConfigurationList;
            buildConfigurations = ( \(projectDebugConfig), \(projectReleaseConfig) );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
        \(appConfigList) = {
            isa = XCConfigurationList;
            buildConfigurations = ( \(appDebugConfig), \(appReleaseConfig) );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
        \(widgetConfigList) = {
            isa = XCConfigurationList;
            buildConfigurations = ( \(widgetDebugConfig), \(widgetReleaseConfig) );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };

/* ── Root Project ────────────────────────────── */

        \(rootObject) = {
            isa = PBXProject;
            attributes = {
                BuildIndependentTargetsInParallel = 1;
                LastSwiftUpdateCheck = 1500;
                LastUpgradeCheck = 1500;
            };
            buildConfigurationList = \(projectConfigList);
            compatibilityVersion = "Xcode 14.0";
            developmentRegion = en;
            hasScannedForEncodings = 0;
            knownRegions = ( en, Base );
            mainGroup = \(mainGroup);
            productRefGroup = \(productsGroup);
            projectDirPath = "";
            projectRoot = "";
            targets = ( \(appTarget), \(widgetTarget) );
        };
    };
    rootObject = \(rootObject);
}
"""

// ── Write ──

let fm = FileManager.default
try fm.createDirectory(atPath: projectDir, withIntermediateDirectories: true)
try content.write(toFile: pbxproj, atomically: true, encoding: .utf8)

// Scheme (shared, so `xcodebuild` finds it without extra flags)
let schemeDir = "\(projectDir)/xcshareddata/xcschemes"
try fm.createDirectory(atPath: schemeDir, withIntermediateDirectories: true)

let scheme = """
<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1500" version="1.7">
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
            <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="\(appTarget)" BuildableName="BatteryPercentage.app" BlueprintName="BatteryPercentage" ReferencedContainer="container:BatteryPercentage.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="\(appTarget)" BuildableName="BatteryPercentage.app" BlueprintName="BatteryPercentage" ReferencedContainer="container:BatteryPercentage.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
</Scheme>
"""

try scheme.write(toFile: "\(schemeDir)/BatteryPercentage.xcscheme", atomically: true, encoding: .utf8)

print("✓ Generated \(projectDir)")
