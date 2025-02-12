module Docs
  class Vueuse
    class EntriesFilter < Docs::EntriesFilter
      # window.__VP_SITE_DATA__.themeConfig.sidebar['/core/']
      SIDEBAR_TYPES = [
        {
          "text": "State",
          "items": [
            {
              "text": "createGlobalState",
              "link": "/shared/createGlobalState/"
            },
            {
              "text": "createInjectionState",
              "link": "/shared/createInjectionState/"
            },
            {
              "text": "createSharedComposable",
              "link": "/shared/createSharedComposable/"
            },
            {
              "text": "injectLocal",
              "link": "/shared/injectLocal/"
            },
            {
              "text": "provideLocal",
              "link": "/shared/provideLocal/"
            },
            {
              "text": "useAsyncState",
              "link": "/core/useAsyncState/"
            },
            {
              "text": "useDebouncedRefHistory",
              "link": "/core/useDebouncedRefHistory/"
            },
            {
              "text": "useLastChanged",
              "link": "/shared/useLastChanged/"
            },
            {
              "text": "useLocalStorage",
              "link": "/core/useLocalStorage/"
            },
            {
              "text": "useManualRefHistory",
              "link": "/core/useManualRefHistory/"
            },
            {
              "text": "useRefHistory",
              "link": "/core/useRefHistory/"
            },
            {
              "text": "useSessionStorage",
              "link": "/core/useSessionStorage/"
            },
            {
              "text": "useStorage",
              "link": "/core/useStorage/"
            },
            {
              "text": "useStorageAsync",
              "link": "/core/useStorageAsync/"
            },
            {
              "text": "useThrottledRefHistory",
              "link": "/core/useThrottledRefHistory/"
            }
          ]
        },
        {
          "text": "Elements",
          "items": [
            {
              "text": "useActiveElement",
              "link": "/core/useActiveElement/"
            },
            {
              "text": "useDocumentVisibility",
              "link": "/core/useDocumentVisibility/"
            },
            {
              "text": "useDraggable",
              "link": "/core/useDraggable/"
            },
            {
              "text": "useDropZone",
              "link": "/core/useDropZone/"
            },
            {
              "text": "useElementBounding",
              "link": "/core/useElementBounding/"
            },
            {
              "text": "useElementSize",
              "link": "/core/useElementSize/"
            },
            {
              "text": "useElementVisibility",
              "link": "/core/useElementVisibility/"
            },
            {
              "text": "useIntersectionObserver",
              "link": "/core/useIntersectionObserver/"
            },
            {
              "text": "useMouseInElement",
              "link": "/core/useMouseInElement/"
            },
            {
              "text": "useMutationObserver",
              "link": "/core/useMutationObserver/"
            },
            {
              "text": "useParentElement",
              "link": "/core/useParentElement/"
            },
            {
              "text": "useResizeObserver",
              "link": "/core/useResizeObserver/"
            },
            {
              "text": "useWindowFocus",
              "link": "/core/useWindowFocus/"
            },
            {
              "text": "useWindowScroll",
              "link": "/core/useWindowScroll/"
            },
            {
              "text": "useWindowSize",
              "link": "/core/useWindowSize/"
            }
          ]
        },
        {
          "text": "Browser",
          "items": [
            {
              "text": "useBluetooth",
              "link": "/core/useBluetooth/"
            },
            {
              "text": "useBreakpoints",
              "link": "/core/useBreakpoints/"
            },
            {
              "text": "useBroadcastChannel",
              "link": "/core/useBroadcastChannel/"
            },
            {
              "text": "useBrowserLocation",
              "link": "/core/useBrowserLocation/"
            },
            {
              "text": "useClipboard",
              "link": "/core/useClipboard/"
            },
            {
              "text": "useClipboardItems",
              "link": "/core/useClipboardItems/"
            },
            {
              "text": "useColorMode",
              "link": "/core/useColorMode/"
            },
            {
              "text": "useCssVar",
              "link": "/core/useCssVar/"
            },
            {
              "text": "useDark",
              "link": "/core/useDark/"
            },
            {
              "text": "useEventListener",
              "link": "/core/useEventListener/"
            },
            {
              "text": "useEyeDropper",
              "link": "/core/useEyeDropper/"
            },
            {
              "text": "useFavicon",
              "link": "/core/useFavicon/"
            },
            {
              "text": "useFileDialog",
              "link": "/core/useFileDialog/"
            },
            {
              "text": "useFileSystemAccess",
              "link": "/core/useFileSystemAccess/"
            },
            {
              "text": "useFullscreen",
              "link": "/core/useFullscreen/"
            },
            {
              "text": "useGamepad",
              "link": "/core/useGamepad/"
            },
            {
              "text": "useImage",
              "link": "/core/useImage/"
            },
            {
              "text": "useMediaControls",
              "link": "/core/useMediaControls/"
            },
            {
              "text": "useMediaQuery",
              "link": "/core/useMediaQuery/"
            },
            {
              "text": "useMemory",
              "link": "/core/useMemory/"
            },
            {
              "text": "useObjectUrl",
              "link": "/core/useObjectUrl/"
            },
            {
              "text": "usePerformanceObserver",
              "link": "/core/usePerformanceObserver/"
            },
            {
              "text": "usePermission",
              "link": "/core/usePermission/"
            },
            {
              "text": "usePreferredColorScheme",
              "link": "/core/usePreferredColorScheme/"
            },
            {
              "text": "usePreferredContrast",
              "link": "/core/usePreferredContrast/"
            },
            {
              "text": "usePreferredDark",
              "link": "/core/usePreferredDark/"
            },
            {
              "text": "usePreferredLanguages",
              "link": "/core/usePreferredLanguages/"
            },
            {
              "text": "usePreferredReducedMotion",
              "link": "/core/usePreferredReducedMotion/"
            },
            {
              "text": "usePreferredReducedTransparency",
              "link": "/core/usePreferredReducedTransparency/"
            },
            {
              "text": "useScreenOrientation",
              "link": "/core/useScreenOrientation/"
            },
            {
              "text": "useScreenSafeArea",
              "link": "/core/useScreenSafeArea/"
            },
            {
              "text": "useScriptTag",
              "link": "/core/useScriptTag/"
            },
            {
              "text": "useShare",
              "link": "/core/useShare/"
            },
            {
              "text": "useSSRWidth",
              "link": "/core/useSSRWidth/"
            },
            {
              "text": "useStyleTag",
              "link": "/core/useStyleTag/"
            },
            {
              "text": "useTextareaAutosize",
              "link": "/core/useTextareaAutosize/"
            },
            {
              "text": "useTextDirection",
              "link": "/core/useTextDirection/"
            },
            {
              "text": "useTitle",
              "link": "/core/useTitle/"
            },
            {
              "text": "useUrlSearchParams",
              "link": "/core/useUrlSearchParams/"
            },
            {
              "text": "useVibrate",
              "link": "/core/useVibrate/"
            },
            {
              "text": "useWakeLock",
              "link": "/core/useWakeLock/"
            },
            {
              "text": "useWebNotification",
              "link": "/core/useWebNotification/"
            },
            {
              "text": "useWebWorker",
              "link": "/core/useWebWorker/"
            },
            {
              "text": "useWebWorkerFn",
              "link": "/core/useWebWorkerFn/"
            }
          ]
        },
        {
          "text": "Sensors",
          "items": [
            {
              "text": "onClickOutside",
              "link": "/core/onClickOutside/"
            },
            {
              "text": "onElementRemoval",
              "link": "/core/onElementRemoval/"
            },
            {
              "text": "onKeyStroke",
              "link": "/core/onKeyStroke/"
            },
            {
              "text": "onLongPress",
              "link": "/core/onLongPress/"
            },
            {
              "text": "onStartTyping",
              "link": "/core/onStartTyping/"
            },
            {
              "text": "useBattery",
              "link": "/core/useBattery/"
            },
            {
              "text": "useDeviceMotion",
              "link": "/core/useDeviceMotion/"
            },
            {
              "text": "useDeviceOrientation",
              "link": "/core/useDeviceOrientation/"
            },
            {
              "text": "useDevicePixelRatio",
              "link": "/core/useDevicePixelRatio/"
            },
            {
              "text": "useDevicesList",
              "link": "/core/useDevicesList/"
            },
            {
              "text": "useDisplayMedia",
              "link": "/core/useDisplayMedia/"
            },
            {
              "text": "useElementByPoint",
              "link": "/core/useElementByPoint/"
            },
            {
              "text": "useElementHover",
              "link": "/core/useElementHover/"
            },
            {
              "text": "useFocus",
              "link": "/core/useFocus/"
            },
            {
              "text": "useFocusWithin",
              "link": "/core/useFocusWithin/"
            },
            {
              "text": "useFps",
              "link": "/core/useFps/"
            },
            {
              "text": "useGeolocation",
              "link": "/core/useGeolocation/"
            },
            {
              "text": "useIdle",
              "link": "/core/useIdle/"
            },
            {
              "text": "useInfiniteScroll",
              "link": "/core/useInfiniteScroll/"
            },
            {
              "text": "useKeyModifier",
              "link": "/core/useKeyModifier/"
            },
            {
              "text": "useMagicKeys",
              "link": "/core/useMagicKeys/"
            },
            {
              "text": "useMouse",
              "link": "/core/useMouse/"
            },
            {
              "text": "useMousePressed",
              "link": "/core/useMousePressed/"
            },
            {
              "text": "useNavigatorLanguage",
              "link": "/core/useNavigatorLanguage/"
            },
            {
              "text": "useNetwork",
              "link": "/core/useNetwork/"
            },
            {
              "text": "useOnline",
              "link": "/core/useOnline/"
            },
            {
              "text": "usePageLeave",
              "link": "/core/usePageLeave/"
            },
            {
              "text": "useParallax",
              "link": "/core/useParallax/"
            },
            {
              "text": "usePointer",
              "link": "/core/usePointer/"
            },
            {
              "text": "usePointerLock",
              "link": "/core/usePointerLock/"
            },
            {
              "text": "usePointerSwipe",
              "link": "/core/usePointerSwipe/"
            },
            {
              "text": "useScroll",
              "link": "/core/useScroll/"
            },
            {
              "text": "useScrollLock",
              "link": "/core/useScrollLock/"
            },
            {
              "text": "useSpeechRecognition",
              "link": "/core/useSpeechRecognition/"
            },
            {
              "text": "useSpeechSynthesis",
              "link": "/core/useSpeechSynthesis/"
            },
            {
              "text": "useSwipe",
              "link": "/core/useSwipe/"
            },
            {
              "text": "useTextSelection",
              "link": "/core/useTextSelection/"
            },
            {
              "text": "useUserMedia",
              "link": "/core/useUserMedia/"
            }
          ]
        },
        {
          "text": "Network",
          "items": [
            {
              "text": "useEventSource",
              "link": "/core/useEventSource/"
            },
            {
              "text": "useFetch",
              "link": "/core/useFetch/"
            },
            {
              "text": "useWebSocket",
              "link": "/core/useWebSocket/"
            }
          ]
        },
        {
          "text": "Animation",
          "items": [
            {
              "text": "useAnimate",
              "link": "/core/useAnimate/"
            },
            {
              "text": "useInterval",
              "link": "/shared/useInterval/"
            },
            {
              "text": "useIntervalFn",
              "link": "/shared/useIntervalFn/"
            },
            {
              "text": "useNow",
              "link": "/core/useNow/"
            },
            {
              "text": "useRafFn",
              "link": "/core/useRafFn/"
            },
            {
              "text": "useTimeout",
              "link": "/shared/useTimeout/"
            },
            {
              "text": "useTimeoutFn",
              "link": "/shared/useTimeoutFn/"
            },
            {
              "text": "useTimestamp",
              "link": "/core/useTimestamp/"
            },
            {
              "text": "useTransition",
              "link": "/core/useTransition/"
            }
          ]
        },
        {
          "text": "Component",
          "items": [
            {
              "text": "computedInject",
              "link": "/core/computedInject/"
            },
            {
              "text": "createReusableTemplate",
              "link": "/core/createReusableTemplate/"
            },
            {
              "text": "createTemplatePromise",
              "link": "/core/createTemplatePromise/"
            },
            {
              "text": "templateRef",
              "link": "/core/templateRef/"
            },
            {
              "text": "tryOnBeforeMount",
              "link": "/shared/tryOnBeforeMount/"
            },
            {
              "text": "tryOnBeforeUnmount",
              "link": "/shared/tryOnBeforeUnmount/"
            },
            {
              "text": "tryOnMounted",
              "link": "/shared/tryOnMounted/"
            },
            {
              "text": "tryOnScopeDispose",
              "link": "/shared/tryOnScopeDispose/"
            },
            {
              "text": "tryOnUnmounted",
              "link": "/shared/tryOnUnmounted/"
            },
            {
              "text": "unrefElement",
              "link": "/core/unrefElement/"
            },
            {
              "text": "useCurrentElement",
              "link": "/core/useCurrentElement/"
            },
            {
              "text": "useMounted",
              "link": "/core/useMounted/"
            },
            {
              "text": "useTemplateRefsList",
              "link": "/core/useTemplateRefsList/"
            },
            {
              "text": "useVirtualList",
              "link": "/core/useVirtualList/"
            },
            {
              "text": "useVModel",
              "link": "/core/useVModel/"
            },
            {
              "text": "useVModels",
              "link": "/core/useVModels/"
            }
          ]
        },
        {
          "text": "Watch",
          "items": [
            {
              "text": "until",
              "link": "/shared/until/"
            },
            {
              "text": "watchArray",
              "link": "/shared/watchArray/"
            },
            {
              "text": "watchAtMost",
              "link": "/shared/watchAtMost/"
            },
            {
              "text": "watchDebounced",
              "link": "/shared/watchDebounced/"
            },
            {
              "text": "watchDeep",
              "link": "/shared/watchDeep/"
            },
            {
              "text": "watchIgnorable",
              "link": "/shared/watchIgnorable/"
            },
            {
              "text": "watchImmediate",
              "link": "/shared/watchImmediate/"
            },
            {
              "text": "watchOnce",
              "link": "/shared/watchOnce/"
            },
            {
              "text": "watchPausable",
              "link": "/shared/watchPausable/"
            },
            {
              "text": "watchThrottled",
              "link": "/shared/watchThrottled/"
            },
            {
              "text": "watchTriggerable",
              "link": "/shared/watchTriggerable/"
            },
            {
              "text": "watchWithFilter",
              "link": "/shared/watchWithFilter/"
            },
            {
              "text": "whenever",
              "link": "/shared/whenever/"
            }
          ]
        },
        {
          "text": "Reactivity",
          "items": [
            {
              "text": "computedAsync",
              "link": "/core/computedAsync/"
            },
            {
              "text": "computedEager",
              "link": "/shared/computedEager/"
            },
            {
              "text": "computedWithControl",
              "link": "/shared/computedWithControl/"
            },
            {
              "text": "extendRef",
              "link": "/shared/extendRef/"
            },
            {
              "text": "reactify",
              "link": "/shared/reactify/"
            },
            {
              "text": "reactifyObject",
              "link": "/shared/reactifyObject/"
            },
            {
              "text": "reactiveComputed",
              "link": "/shared/reactiveComputed/"
            },
            {
              "text": "reactiveOmit",
              "link": "/shared/reactiveOmit/"
            },
            {
              "text": "reactivePick",
              "link": "/shared/reactivePick/"
            },
            {
              "text": "refAutoReset",
              "link": "/shared/refAutoReset/"
            },
            {
              "text": "refDebounced",
              "link": "/shared/refDebounced/"
            },
            {
              "text": "refDefault",
              "link": "/shared/refDefault/"
            },
            {
              "text": "refThrottled",
              "link": "/shared/refThrottled/"
            },
            {
              "text": "refWithControl",
              "link": "/shared/refWithControl/"
            },
            {
              "text": "syncRef",
              "link": "/shared/syncRef/"
            },
            {
              "text": "syncRefs",
              "link": "/shared/syncRefs/"
            },
            {
              "text": "toReactive",
              "link": "/shared/toReactive/"
            },
            {
              "text": "toRef",
              "link": "/shared/toRef/"
            },
            {
              "text": "toRefs",
              "link": "/shared/toRefs/"
            },
            {
              "text": "toValue",
              "link": "/shared/toValue/"
            }
          ]
        },
        {
          "text": "Array",
          "items": [
            {
              "text": "useArrayDifference",
              "link": "/shared/useArrayDifference/"
            },
            {
              "text": "useArrayEvery",
              "link": "/shared/useArrayEvery/"
            },
            {
              "text": "useArrayFilter",
              "link": "/shared/useArrayFilter/"
            },
            {
              "text": "useArrayFind",
              "link": "/shared/useArrayFind/"
            },
            {
              "text": "useArrayFindIndex",
              "link": "/shared/useArrayFindIndex/"
            },
            {
              "text": "useArrayFindLast",
              "link": "/shared/useArrayFindLast/"
            },
            {
              "text": "useArrayIncludes",
              "link": "/shared/useArrayIncludes/"
            },
            {
              "text": "useArrayJoin",
              "link": "/shared/useArrayJoin/"
            },
            {
              "text": "useArrayMap",
              "link": "/shared/useArrayMap/"
            },
            {
              "text": "useArrayReduce",
              "link": "/shared/useArrayReduce/"
            },
            {
              "text": "useArraySome",
              "link": "/shared/useArraySome/"
            },
            {
              "text": "useArrayUnique",
              "link": "/shared/useArrayUnique/"
            },
            {
              "text": "useSorted",
              "link": "/core/useSorted/"
            }
          ]
        },
        {
          "text": "Time",
          "items": [
            {
              "text": "useCountdown",
              "link": "/core/useCountdown/"
            },
            {
              "text": "useDateFormat",
              "link": "/shared/useDateFormat/"
            },
            {
              "text": "useTimeAgo",
              "link": "/core/useTimeAgo/"
            }
          ]
        },
        {
          "text": "Utilities",
          "items": [
            {
              "text": "createEventHook",
              "link": "/shared/createEventHook/"
            },
            {
              "text": "createUnrefFn",
              "link": "/core/createUnrefFn/"
            },
            {
              "text": "get",
              "link": "/shared/get/"
            },
            {
              "text": "isDefined",
              "link": "/shared/isDefined/"
            },
            {
              "text": "makeDestructurable",
              "link": "/shared/makeDestructurable/"
            },
            {
              "text": "set",
              "link": "/shared/set/"
            },
            {
              "text": "useAsyncQueue",
              "link": "/core/useAsyncQueue/"
            },
            {
              "text": "useBase64",
              "link": "/core/useBase64/"
            },
            {
              "text": "useCached",
              "link": "/core/useCached/"
            },
            {
              "text": "useCloned",
              "link": "/core/useCloned/"
            },
            {
              "text": "useConfirmDialog",
              "link": "/core/useConfirmDialog/"
            },
            {
              "text": "useCounter",
              "link": "/shared/useCounter/"
            },
            {
              "text": "useCycleList",
              "link": "/core/useCycleList/"
            },
            {
              "text": "useDebounceFn",
              "link": "/shared/useDebounceFn/"
            },
            {
              "text": "useEventBus",
              "link": "/core/useEventBus/"
            },
            {
              "text": "useMemoize",
              "link": "/core/useMemoize/"
            },
            {
              "text": "useOffsetPagination",
              "link": "/core/useOffsetPagination/"
            },
            {
              "text": "usePrevious",
              "link": "/core/usePrevious/"
            },
            {
              "text": "useStepper",
              "link": "/core/useStepper/"
            },
            {
              "text": "useSupported",
              "link": "/core/useSupported/"
            },
            {
              "text": "useThrottleFn",
              "link": "/shared/useThrottleFn/"
            },
            {
              "text": "useTimeoutPoll",
              "link": "/core/useTimeoutPoll/"
            },
            {
              "text": "useToggle",
              "link": "/shared/useToggle/"
            },
            {
              "text": "useToNumber",
              "link": "/shared/useToNumber/"
            },
            {
              "text": "useToString",
              "link": "/shared/useToString/"
            }
          ]
        },
        {
          "text": "@Electron",
          "items": [
            {
              "text": "useIpcRenderer",
              "link": "/electron/useIpcRenderer/"
            },
            {
              "text": "useIpcRendererInvoke",
              "link": "/electron/useIpcRendererInvoke/"
            },
            {
              "text": "useIpcRendererOn",
              "link": "/electron/useIpcRendererOn/"
            },
            {
              "text": "useZoomFactor",
              "link": "/electron/useZoomFactor/"
            },
            {
              "text": "useZoomLevel",
              "link": "/electron/useZoomLevel/"
            }
          ],
          "link": "/electron/README"
        },
        {
          "text": "@Firebase",
          "items": [
            {
              "text": "useAuth",
              "link": "/firebase/useAuth/"
            },
            {
              "text": "useFirestore",
              "link": "/firebase/useFirestore/"
            },
            {
              "text": "useRTDB",
              "link": "/firebase/useRTDB/"
            }
          ],
          "link": "/firebase/README"
        },
        {
          "text": "@Head",
          "items": [
            {
              "text": "createHead",
              "link": "https://github.com/vueuse/head#api"
            },
            {
              "text": "useHead",
              "link": "https://github.com/vueuse/head#api"
            }
          ],
          "link": "https://github.com/vueuse/head#api"
        },
        {
          "text": "@Integrations",
          "items": [
            {
              "text": "useAsyncValidator",
              "link": "/integrations/useAsyncValidator/"
            },
            {
              "text": "useAxios",
              "link": "/integrations/useAxios/"
            },
            {
              "text": "useChangeCase",
              "link": "/integrations/useChangeCase/"
            },
            {
              "text": "useCookies",
              "link": "/integrations/useCookies/"
            },
            {
              "text": "useDrauu",
              "link": "/integrations/useDrauu/"
            },
            {
              "text": "useFocusTrap",
              "link": "/integrations/useFocusTrap/"
            },
            {
              "text": "useFuse",
              "link": "/integrations/useFuse/"
            },
            {
              "text": "useIDBKeyval",
              "link": "/integrations/useIDBKeyval/"
            },
            {
              "text": "useJwt",
              "link": "/integrations/useJwt/"
            },
            {
              "text": "useNProgress",
              "link": "/integrations/useNProgress/"
            },
            {
              "text": "useQRCode",
              "link": "/integrations/useQRCode/"
            },
            {
              "text": "useSortable",
              "link": "/integrations/useSortable/"
            }
          ],
          "link": "/integrations/README"
        },
        {
          "text": "@Math",
          "items": [
            {
              "text": "createGenericProjection",
              "link": "/math/createGenericProjection/"
            },
            {
              "text": "createProjection",
              "link": "/math/createProjection/"
            },
            {
              "text": "logicAnd",
              "link": "/math/logicAnd/"
            },
            {
              "text": "logicNot",
              "link": "/math/logicNot/"
            },
            {
              "text": "logicOr",
              "link": "/math/logicOr/"
            },
            {
              "text": "useAbs",
              "link": "/math/useAbs/"
            },
            {
              "text": "useAverage",
              "link": "/math/useAverage/"
            },
            {
              "text": "useCeil",
              "link": "/math/useCeil/"
            },
            {
              "text": "useClamp",
              "link": "/math/useClamp/"
            },
            {
              "text": "useFloor",
              "link": "/math/useFloor/"
            },
            {
              "text": "useMath",
              "link": "/math/useMath/"
            },
            {
              "text": "useMax",
              "link": "/math/useMax/"
            },
            {
              "text": "useMin",
              "link": "/math/useMin/"
            },
            {
              "text": "usePrecision",
              "link": "/math/usePrecision/"
            },
            {
              "text": "useProjection",
              "link": "/math/useProjection/"
            },
            {
              "text": "useRound",
              "link": "/math/useRound/"
            },
            {
              "text": "useSum",
              "link": "/math/useSum/"
            },
            {
              "text": "useTrunc",
              "link": "/math/useTrunc/"
            }
          ],
          "link": "/math/README"
        },
        {
          "text": "@Motion",
          "items": [
            {
              "text": "useElementStyle",
              "link": "https://motion.vueuse.org/api/use-element-style"
            },
            {
              "text": "useElementTransform",
              "link": "https://motion.vueuse.org/api/use-element-transform"
            },
            {
              "text": "useMotion",
              "link": "https://motion.vueuse.org/api/use-motion"
            },
            {
              "text": "useMotionProperties",
              "link": "https://motion.vueuse.org/api/use-motion-properties"
            },
            {
              "text": "useMotionVariants",
              "link": "https://motion.vueuse.org/api/use-motion-variants"
            },
            {
              "text": "useSpring",
              "link": "https://motion.vueuse.org/api/use-spring"
            }
          ],
          "link": "https://motion.vueuse.org/api/use-element-style"
        },
        {
          "text": "@Router",
          "items": [
            {
              "text": "useRouteHash",
              "link": "/router/useRouteHash/"
            },
            {
              "text": "useRouteParams",
              "link": "/router/useRouteParams/"
            },
            {
              "text": "useRouteQuery",
              "link": "/router/useRouteQuery/"
            }
          ],
          "link": "/router/README"
        },
        {
          "text": "@RxJS",
          "items": [
            {
              "text": "from",
              "link": "/rxjs/from/"
            },
            {
              "text": "toObserver",
              "link": "/rxjs/toObserver/"
            },
            {
              "text": "useExtractedObservable",
              "link": "/rxjs/useExtractedObservable/"
            },
            {
              "text": "useObservable",
              "link": "/rxjs/useObservable/"
            },
            {
              "text": "useSubject",
              "link": "/rxjs/useSubject/"
            },
            {
              "text": "useSubscription",
              "link": "/rxjs/useSubscription/"
            },
            {
              "text": "watchExtractedObservable",
              "link": "/rxjs/watchExtractedObservable/"
            }
          ],
          "link": "/rxjs/README"
        },
        {
          "text": "@SchemaOrg",
          "items": [
            {
              "text": "createSchemaOrg",
              "link": "https://vue-schema-org.netlify.app/api/core/create-schema-org.html"
            },
            {
              "text": "useSchemaOrg",
              "link": "https://vue-schema-org.netlify.app/api/core/use-schema-org.html"
            }
          ],
          "link": "https://vue-schema-org.netlify.app/api/core/create-schema-org.html"
        },
        {
          "text": "@Sound",
          "items": [
            {
              "text": "useSound",
              "link": "https://github.com/vueuse/sound#examples"
            }
          ],
          "link": "https://github.com/vueuse/sound#examples"
        }
      ]

      def get_name
        name = at_css('h1').content
        name.sub! %r{\s*#\s*}, ''
        name
      end

      def get_type
        return 'Guide' if slug == 'export-size'
        return 'Guide' if slug == 'functions'
        return 'Guide' if slug == 'guidelines'
        return 'Guide' if slug.start_with? 'guide'
        SIDEBAR_TYPES.find { |i| i[:items].find { |j| j[:link][1..].downcase.start_with? slug.downcase } }[:text]
      end
    end
  end
end
