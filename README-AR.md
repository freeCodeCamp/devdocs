## DevDocs
يجمع بين العديد من وثائق المطورين في واجهة مستخدم ويب نظيفة ومنظمة مع البحث الفوري ، والدعم في وضع عدم الاتصال ، وإصدار الهاتف المحمول
.والسمات الداكنة ، واختصارات لوحة المفاتيح ، والمزيد

تم إنشائه بواسطة
[Thibaut Courouble](https://thibaut.me/)
ويتم تشغيله بواسطة
[freeCodeCamp](https://www.freecodecamp.org/)
نحن نبحث حاليا عن المشرفين
يرجى التواصل Gitter 
إذا كنت ترغب في الانضمام إلى الفريق
لتتبع أخبار التطوير والتنمية

انضم إلى غرفة محادثة المساهم على-  Gitter  
شاهد المستودع على GitHub - 
تابعنا على Twitter-  
جدول المحتويات: بداية سريعة · الرؤية · التطبيق ·  Scraper · الأوامر · المساهمة · التوثيق · المشاريع ذات الصلة · الترخيص · أسئلة؟

**بداية سريعة**


- ما لم تكن ترغب في المساهمة في المشروع ، نوصي باستخدام الإصدار على devdocs.io. 
إنه مُحدَّث ويعمل بدون اتصال بالإنترنت

يتكون
DevDocs من جزئين :Ruby التي تنشئ الوثائق والبيانات الوصفية ، وتطبيق JavaScript مدعوم من تطبيق Sinatra الصغير

يتطلب DevDocs Ruby 2.6.x و libcurl و تشغيل JavaScript مدعومًا بواسطة ExecJS (مضمن في OS X و Windows ؛ Node.js على Linux). بمجرد تثبيت هذه ، قم بتشغيل الأوامر التالية:

git clone https://github.com/freeCodeCamp/devdocs.git && cd devdocs
gem install bundler
bundle install
bundle exec thor docs:download --default
bundle exec rackup

أخيرًا ، قم بتوجيه المستعرض الخاص بك إلى localhost: 9292 (سيستغرق الطلب الأول بضع ثوانٍ لتجميع الأصول). أنت الان جاهز تمامًا

The thor وثائق :

لتنزيل الوثائق التي تم إنشاؤها مسبقًا من خوادم DevDocs (على سبيل المثال ، Thor docs: تنزيل html css). يمكنك الاطلاع على قائمة الوثائق والإصدارات المتاحة من خلال تشغيل قائمة المستندات. لتحديث جميع الوثائق التي تم تنزيلها ، قم بتشغيل المستندات: تنزيل - مثبت. لتنزيل جميع الوثائق المتوفرة لهذا المشروع وتثبيتها ، قم بتشغيل المستندات: تنزيل -الكل.

ملاحظة: لا توجد حاليًا آلية تحديث بخلاف git pull origin main لتحديث الكود والمستندات: تنزيل - مُثبَّت لتنزيل أحدث إصدار من المستندات. للبقاء على اطلاع بالإصدارات الجديدة ، تأكد من مشاهدة هذا المستودع.



بدلاً من ذلك ، يمكن بدء DevDocs كحاوية Docker:

# بالبداية الصورة 
git clone https://github.com/freeCodeCamp/devdocs.git && cd devdocs
docker build -t thibaut/devdocs .

# نهاية استخدم  DevDocs container (access http://localhost:9292)
docker run --name devdocs -d -p 9292:9292 thibaut/devdocs

**الرؤية**

يهدف DevDocs إلى جعل قراءة الوثائق المرجعية والبحث فيها سريعة وسهلة وممتعة.

الأهداف الرئيسية للتطبيق هي: جعل أوقات التحميل قصيرة قدر الإمكان ؛ تحسين جودة نتائج البحث وسرعتها وترتيبها ؛ تعظيم استخدام التخزين المؤقت وتحسينات الأداء الأخرى ؛ الحفاظ على واجهة مستخدم نظيفة وقابلة للقراءة ؛ أن تكون تعمل بكامل طاقتها في وضع عدم الاتصال ؛ دعم التنقل الكامل باستخدام لوحة المفاتيح ؛ تقليل "تبديل السياق" باستخدام أسلوب طباعة وتصميم متسقين في جميع الوثائق ؛ تقليل الفوضى من خلال التركيز على فئة معينة من المحتوى (API / المرجع) وفهرسة الحد الأدنى فقط من البرامج المفيدة لمعظم المطورين.

ملاحظة: DevDocs ليس دليل برمجة ولا محرك بحث. يتم سحب كل المحتوى الخاص بنا من مصادر جهات خارجية ولا ينوي المشروع التنافس مع محركات البحث ذات النص الكامل. العمود الفقري لها هو البيانات الوصفية. يتم تحديد كل جزء من المحتوى بسلسلة فريدة "واضحة" وقصيرة. البرامج التعليمية والأدلة والمحتويات الأخرى التي لا تفي بهذا المطلب خارج نطاق المشروع.


**التطبيق**

تطبيق الويب عبارة عن JavaScript من جانب العميل ، ومكتوب بلغة CoffeeScript ، ويتم تشغيله بواسطة تطبيق Sinatra / Sprockets الصغير. يعتمد على الملفات التي تم إنشاؤها بواسطة  Scraper.

كانت العديد من قرارات تصميم الكود مدفوعة بحقيقة أن التطبيق يستخدم XHR لتحميل المحتوى مباشرة في الإطار الرئيسي. يتضمن ذلك تجريد المستندات الأصلية من معظم ترميز HTML الخاص بهم (مثل البرامج النصية وأوراق الأنماط) لتجنب تلويث الإطار الرئيسي ، وبدء جميع أسماء فئات CSS بشرطة سفلية لمنع التعارضات.

العامل الدافع الآخر هو الأداء وحقيقة أن كل شيء يحدث في المتصفح. يتم استخدام عامل الخدمة (الذي يأتي مع مجموعة القيود الخاصة به) والتخزين المحلي لتسريع وقت التمهيد ، بينما يتم التحكم في استهلاك الذاكرة من خلال السماح للمستخدم باختيار مجموعة المستندات الخاصة به. تظل خوارزمية البحث بسيطة لأنها تحتاج إلى أن تكون سريعة حتى البحث في 100000 سلسلة.

نظرًا لكون DevDocs أداة مطور ، فإن متطلبات المتصفح عالية:

الإصدارات الحديثة من Firefox أو Chrome أو Opera
اخر إصدار من Firefox, Chrome, or Opera
Safari 11.1+
Edge 17+
iOS 11.3+
يتيح ذلك للشفرة الاستفادة من أحدث واجهات برمجة تطبيقات DOM و HTML5 وجعل تطوير DevDocs أكثر متعة! 


 **Scraper**
 
 الكاشطة مسؤولة عن إنشاء ملفات التوثيق والفهرس (البيانات الوصفية) التي يستخدمها التطبيق. إنه مكتوب بلغة Ruby ضمن وحدة Docs.

يوجد حاليًا نوعان من برامج Scraper: UrlScraper الذي يقوم بتنزيل الملفات عبر HTTP و FileScraper الذي يقرأها من نظام الملفات المحلي. يقوم كلاهما بعمل نسخ من مستندات HTML ، ويتابعان بشكل متكرر الروابط التي تطابق مجموعة من القواعد ويطبقان جميع أنواع التعديلات ، بالإضافة إلى إنشاء فهرس للملفات وبياناتها الوصفية. يتم تحليل المستندات باستخدام Nokogiri.

تشمل التعديلات التي تم إجراؤها على كل وثيقة ما يلي:
 
 
 إزالة محتوى مثل بنية المستند (<html> و <head> وما إلى ذلك) والتعليقات والعقد الفارغة وما إلى ذلك.
إصلاح الروابط (على سبيل المثال لإزالة التكرارات)
استبدال جميع عناوين URL الخارجية (غير المقتبسة) بنظيرتها المؤهلة بالكامل
استبدال جميع عناوين URL الداخلية (المقتبسة) بنظيرتها النسبية غير المؤهلة
إضافة محتوى ، مثل العنوان والارتباط بالمستند الأصلي
ضمان إبراز بناء الجملة الصحيح باستخدام Prism
يتم تطبيق هذه التعديلات عبر مجموعة من المرشحات باستخدام مكتبة HTML :: Pipeline. تتضمن كل Scraper مرشحات خاصة بها ، أحدها مكلف بمعرفة البيانات الوصفية للصفحات.

والنتيجة النهائية هي مجموعة من أجزاء HTML المعيارية وملفي JSON (فهرس + بيانات غير متصلة بالإنترنت). نظرًا لأنه يتم تحميل ملفات الفهرس بشكل منفصل عن طريق التطبيق وفقًا لتفضيلات المستخدم ، يقوم Scraper أيضًا بإنشاء ملف بيان JSON يحتوي على معلومات حول الوثائق المتاحة حاليًا على النظام (مثل الاسم والإصدار وتاريخ التحديث وما إلى ذلك).

يتوفر المزيد من المعلومات حول أدوات Scraper والمرشحات في مجلد المستندات.
  
  
  
**الأوامر المتوفرة**
تستخدم واجهة سطر الأوامر Thor. لمشاهدة جميع الأوامر والخيارات ، قم بتشغيل قائمة من جذر المشروع.
  
# السيرفر
rackup              # لبدء السيرفر(ctrl+c to stop)
rackup --help       # قائمة من خيارات السيرفر

# Docs
thor docs:list      #  قائمة الوثائق المتوفرة
thor docs:download  # لتحميل وثيقة أو أكثر
thor docs:manifest  # إنشاء ملف البيان الذي يستخدمه التطبيق
thor docs:generate  # تطوير scraper للوثيقة
thor docs:page      # تطوير scraper للصفحة
thor docs:package   # مجموعة من الوثائق لاستخدامها مع  docs:download
thor docs:clean     # حذف مجموعة الوثائق

# Console
thor console        # ابدأ REPL
thor console:docs   # ابدأ REPL  في "Docs" module

# أختبر سريعا من خلال تشغيل الامر  "test" command. 
#  "help test" استخدم الامر .
thor test:all       # لاختبار الكل
thor test:docs      # لاختبار  "Docs" 
thor test:app       # لتشغيل اختبار التطبيق

# الملفات المساعدة
thor assets:compile # تجميع (غير مطلوب في وضع التطوير)
thor assets:clean   # مسح القديم 

إذا تم تثبيت إصدارات متعددة من Ruby على نظامك ، فيجب تشغيل الأوامر من خلال bundle exec.

**المساهمة**
  
نرحب بالمساهمات. يرجى قراءة المبادئ التوجيهية للمساهمة.

**التوثيق**
  
[إضافة الوثائق](https://github.com/freeCodeCamp/devdocs/blob/main/docs/adding-docs.md)
[Scraper مرجع ال](https://github.com/freeCodeCamp/devdocs/blob/main/docs/scraper-reference.md)
[مرجع للتصفية](https://github.com/freeCodeCamp/devdocs/blob/main/docs/filter-reference.md)
[دليل المشرفين](https://github.com/freeCodeCamp/devdocs/blob/main/docs/maintainers.md)

  

| المشروع                                                                                                 | الوصف                                                            | اخر تحديث                                                                                                                                                               |
|---------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Chrome web app](https://chrome.google.com/webstore/detail/devdocs/mnfehgbmkapmjnhcnbodoamcioleeooe)    | Chrome Web App which adds a shortcut to DevDocs apps page.             | N/A                                                                                                                                                                        |
| [Ubuntu Touch app](https://uappexplorer.com/app/devdocsunofficial.berkes)                               | Application for devices running Ubuntu Touch.                          | N/A                                                                                                                                                                        |
| [Sublime Text plugin](https://sublime.wbond.net/packages/DevDocs)                                       | Sublime Text plugin to search DevDocs by selection or by input.        | [![Latest GitHub commit](https://img.shields.io/github/last-commit/vitorbritto/sublime-devdocs?logo=github&label)](https://github.com/vitorbritto/sublime-devdocs)         |
| [Atom plugin](https://atom.io/packages/devdocs)                                                         | Atom plugin adding the `doc` command to search DevDocs.                | [![Latest GitHub commit](https://img.shields.io/github/last-commit/masnun/atom-devdocs?logo=github&label)](https://github.com/masnun/atom-devdocs)                         |
| [gruehle/dev-docs-viewer](https://github.com/gruehle/dev-docs-viewer)                                   | Brackets extension for searching and viewing DevDocs content.          | [![Latest GitHub commit](https://img.shields.io/github/last-commit/gruehle/dev-docs-viewer?logo=github&label)](https://github.com/gruehle/dev-docs-viewer)                 |
| [naquad/devdocs-shell](https://github.com/naquad/devdocs-shell)                                         | GTK shell with Vim integration.                                        | [![Latest GitHub commit](https://img.shields.io/github/last-commit/naquad/devdocs-shell?logo=github&label)](https://github.com/naquad/devdocs-shell)                       |
| [skeeto/devdocs-lookup](https://github.com/skeeto/devdocs-lookup)                                       | Quick Emacs API lookup on DevDocs.                                     | [![Latest GitHub commit](https://img.shields.io/github/last-commit/skeeto/devdocs-lookup?logo=github&label)](https://github.com/skeeto/devdocs-lookup)                     |
| [yannickglt/alfred-devdocs](https://github.com/yannickglt/alfred-devdocs)                               | Alfred workflow for DevDocs.                                           | [![Latest GitHub commit](https://img.shields.io/github/last-commit/yannickglt/alfred-devdocs?logo=github&label)](https://github.com/yannickglt/alfred-devdocs)             |
| [waiting-for-dev/vim-www](https://github.com/waiting-for-dev/vim-www)                                   | Vim search plugin with DevDocs in its defaults.                        | [![Latest GitHub commit](https://img.shields.io/github/last-commit/waiting-for-dev/vim-www?logo=github&label)](https://github.com/waiting-for-dev/vim-www)                 |
| [vscode-devdocs for VS Code](https://marketplace.visualstudio.com/items?itemName=akfish.vscode-devdocs) | VS Code plugin to open and search DevDocs inside VS Code.              | [![Latest GitHub commit](https://img.shields.io/github/last-commit/akfish/vscode-devdocs?logo=github&label)](https://github.com/akfish/vscode-devdocs)                     |
| [devdocs for VS Code](https://marketplace.visualstudio.com/items?itemName=deibit.devdocs)               | VS Code plugin to open the browser to search selected text on DevDocs. | [![Latest GitHub commit](https://img.shields.io/github/last-commit/deibit/vscode-devdocs?logo=github&label)](https://github.com/deibit/vscode-devdocs)                     |
| [egoist/devdocs-desktop](https://github.com/egoist/devdocs-desktop)                                     | Cross-platform desktop application for DevDocs.                        | [![Latest GitHub commit](https://img.shields.io/github/last-commit/egoist/devdocs-desktop?logo=github&label)](https://github.com/egoist/devdocs-desktop)                   |
| [qwfy/doc-browser](https://github.com/qwfy/doc-browser)                                                 | Native Linux app that supports DevDocs docsets.                        | [![Latest GitHub commit](https://img.shields.io/github/last-commit/qwfy/doc-browser?logo=github&label)](https://github.com/qwfy/doc-browser)                               |
| [hardpixel/devdocs-desktop](https://github.com/hardpixel/devdocs-desktop)                               | GTK3 application for DevDocs with search integrated in the headerbar.  | [![Latest GitHub commit](https://img.shields.io/github/last-commit/hardpixel/devdocs-desktop?logo=github&label)](https://github.com/hardpixel/devdocs-desktop)             |
| [dteoh/devdocs-macos](https://github.com/dteoh/devdocs-macos)                                           | Native macOS application for DevDocs.                                  | [![Latest GitHub commit](https://img.shields.io/github/last-commit/dteoh/devdocs-macos?logo=github&label)](https://github.com/dteoh/devdocs-macos)                         |
| [Merith-TK/devdocs_webapp_kotlin](https://github.com/Merith-TK/devdocs_webapp_kotlin)                   | Android application which shows DevDocs in a webview.                  | [![Latest GitHub commit](https://img.shields.io/github/last-commit/Merith-TK/devdocs_webapp_kotlin?logo=github&label)](https://github.com/Merith-TK/devdocs_webapp_kotlin) |
| [astoff/devdocs.el](https://github.com/astoff/devdocs.el)                                               | Emacs viewer for DevDocs                                               | [![Latest GitHub commit](https://img.shields.io/github/last-commit/astoff/devdocs.el?logo=github&label)](https://github.com/astoff/devdocs.el)                             |
| [DevDocs Tab for VS Code](https://github.com/mohamed3nan/DevDocs-Tab)                                   | VS Code extension to search for documentation on DevDocs.io faster by displaying it in a tab inside VS Code.| [![Latest GitHub commit](https://img.shields.io/github/last-commit/mohamed3nan/DevDocs-Tab?logo=github&label)](https://github.com/mohamed3nan/DevDocs-Tab)                             |
  
  
  
  
**حقوق النشر/الترخيص**
  
حقوق الطبع والنشر 2013–2021 Thibaut Courouble ومساهمين آخرين

تم ترخيص هذا البرنامج بموجب شروط ترخيص Mozilla العام v2.0. انظر حقوق النشر وملفات الترخيص.
[حقوق النشر](https://github.com/freeCodeCamp/devdocs/blob/main/COPYRIGHT)

يُرجى عدم استخدام اسم DevDocs للمصادقة على المنتجات المشتقة من هذا البرنامج أو الترويج لها بدون إذن المشرفين ، باستثناء ما قد يكون ضروريًا للامتثال لمتطلبات الإشعار / الإسناد.

نود أيضًا أن يُنسب أي ملف توثيق تم إنشاؤه باستخدام هذا البرنامج إلى DevDocs. لنكن منصفين لجميع المساهمين من خلال منح الائتمان عند استحقاق الائتمان. شكرا!

**أسئلة**
  
إذا كان لديك أي أسئلة ، فلا تتردد في طرحها على غرفة محادثة على Gitter.
  
  
  
  
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 



























