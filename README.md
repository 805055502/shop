# FOMO 介绍页

这是一个无构建步骤的静态落地页。介绍页规范网址为 `https://fomo9527.top/`，购买入口为外部站点 `https://wzyp.cn/shop/fomo`。

## 搜索目标

重点查询词为 **ChatGPT 代充、Claude 代充、Codex 代充、Grok 代充**，同时观察 ChatGPT、Claude、Codex、Grok 单品牌词。查询词不等于独立商品分类：本店 Codex 相关需求归入 ChatGPT 套餐，仅作关联关键词覆盖，不单独介绍或列为一种代充服务。页面服务说明按实际商品分为 ChatGPT、Claude、Gemini、Grok，服务内容、购买方式与实际店铺保持一致；不堆砌关键词、不添加不存在的商品。单品牌词意图较宽，不能承诺以介绍页覆盖所有相关搜索。

目标验收顺序为：**部署正式版本 → 各平台完成所有权验证 → 提交网址 → 确认抓取与索引 → 观察目标查询词的展示和点击**。2026-10-20 已通过用户登录的 Google Search Console 核实：首页已收录，上次抓取为 2026-10-16 15:56:07，Googlebot 智能手机版抓取成功，Google 选择的规范网址为 `https://fomo9527.top/`；sitemap 上次读取为 10 月 18 日，状态成功，发现 1 个页面。当前已报告的搜索展示、点击和外链均为 0（报告可能延迟，外链报告也不代表全部链接），未检测到人工处置或安全问题。用户的域名搜索截图也确认首页能展示；下一阶段验收服务词的展示和点击，而非只验收域名能搜到。其他平台状态仍以后台为准，不承诺指定排名。

### 关键词与独立页面

- `/` 保留四种真实服务的精简入口和一个购买按钮；现有 ChatGPT 标题链接至 `/chatgpt/`，不靠新增首页段落覆盖近义词。
- `/chatgpt/` 承接 ChatGPT / GPT 代充、Plus / Pro 月卡的选购与兑换问题，包含真实在售选项、Plus 账号条件、卡密流程和查单入口。Codex 仍沿用首页的归属说明，不单独设商品或页面。
- 该页资料核验于 2026-10-20 的公开店铺与 Plus 商品说明。价格、库存和权益经常变化，不写入固定报价或未核实的官方额度。新增页面独立 self-canonical，已纳入 sitemap；当日已发布，Google 实时测试通过，但尚未确认正式收录。
- 需要扩大其他服务词覆盖时，先核实对应商品的独立用途和流程，再建设有区别的页面；不批量生成只替换品牌或“开通/购买/升级”字样的相似页。Google 当前指南重视实用、准确的内容，没有排名字数门槛。[有用内容指南](https://developers.google.com/search/docs/fundamentals/creating-helpful-content)、[SEO 入门指南](https://developers.google.com/search/docs/fundamentals/seo-starter-guide)
- 外链使用主域 `https://fomo9527.top/`。可在可编辑的真实店铺/品牌资料中使用“天才程序员加油站”作为自然链接文字；尚未对外发布任何公告或帖子，也未购买或群发链接。

## 部署

将 `index.html`、`styles.css`、`chatgpt/` 文件夹、`404.html`、`favicon.png`、`favicon.ico`、`robots.txt`、`sitemap.xml`、`_redirects`、`indexnow-key.txt` 上传到站点根目录。`favicon.svg` 保留为图标源文件，可一并部署；`README.md` 与 `scripts/` 不需要上传。首页及资源应通过 HTTPS 公开访问；`robots.txt` 与 IndexNow 验证文件应返回纯文本，`sitemap.xml` 应返回 XML，不能被重写为首页 HTML。

当前生产环境为 GitHub `main` 分支触发的 Workers Static Assets 自动部署，命令为 `npx wrangler deploy`，自动识别仓库根目录。`.assetsignore` 使用公开资源白名单，避免 README、脚本和仓库配置被作为页面发布；增加新资源时同步维护白名单。[Cloudflare 资源排除说明](https://developers.cloudflare.com/workers/static-assets/binding/#ignoring-assets)

搜索图标使用 96×96 PNG，另提供 16/32/48 像素 ICO；沿用现有 SVG 的外观，不增加首页内容。Google 当前搜索图标规范列出的格式不包含 SVG，PNG/ICO 属于支持格式。[Google 搜索图标规范](https://developers.google.com/search/docs/appearance/favicon-in-search)

根目录 `_redirects` 已配置 `/index.html / 301`，适用于 Cloudflare Pages 和 Workers Static Assets；`404.html` 用于缺失页面，并阻止 Pages 默认 SPA fallback 将未知路径当作首页。**这两个文件需部署后才生效**。若请求由自定义 Worker 代码或 Pages Functions 处理，应在实际处理代码中实现相同行为；`_redirects` 不会覆盖这些代码的响应。[Pages 跳转说明](https://developers.cloudflare.com/pages/configuration/redirects/)、[Workers Static Assets 跳转说明](https://developers.cloudflare.com/workers/static-assets/redirects/)、[Pages 404 说明](https://developers.cloudflare.com/pages/configuration/serving-pages/)

页面 canonical、分享链接、结构化数据和 sitemap 使用同一主域。`www.fomo9527.top`、HTTP 访问及显式 `/index.html` 应由服务器或 Cloudflare 返回 **301 或 308**，统一到 HTTPS 非 www 地址。域名/协议跳转保留原路径及查询参数；只有 `/index.html` 合并为 `/`。例如：

| 请求 | 预期结果 |
| --- | --- |
| `https://fomo9527.top/` | `200` 首页 |
| `https://www.fomo9527.top/?utm_source=test` | `301/308` → `https://fomo9527.top/?utm_source=test` |
| `http://fomo9527.top/robots.txt` | `301/308` → `https://fomo9527.top/robots.txt` |
| `https://www.fomo9527.top/index.html?utm_source=test` | `301/308` → `https://fomo9527.top/?utm_source=test` |
| `https://fomo9527.top/not-a-real-page` | `404`，不能返回首页 `200` |

2026-10-20 已在 Cloudflare 发布并验证 `SEO - HTTPS apex canonical`：HTTP 与 www 返回 `301` 到 HTTPS 主域，路径及查询参数保留，HTTPS 主域仍返回 `200`。显式首页跳转由已部署的 `_redirects` 处理。以下保留为重建配置时的参考，避免重复创建规则。

### Cloudflare Redirect Rules

适用于通过 Cloudflare 代理的两个域名。先确认根域与 www 的 DNS 均已开启代理，且 HTTPS 证书覆盖两个域名。在域名控制台进入 **Rules → Redirect Rules**（新版界面可从 **Rules → Overview → Create rule → Redirect Rule** 进入），依次创建两条 Single Redirect 规则：

1. **合并显式首页**，放在下一条规则前。匹配条件使用自定义表达式：

   ```text
   (http.host in {"fomo9527.top" "www.fomo9527.top"} and http.request.uri.path eq "/index.html")
   ```

   动作选择 Static，目标 `https://fomo9527.top/`，状态码 `301`，开启 **Preserve query string**。

2. **统一 www 与 HTTP**，匹配条件：

   ```text
   (http.host eq "www.fomo9527.top" or (http.host eq "fomo9527.top" and starts_with(http.request.full_uri, "http://")))
   ```

   动作选择 Dynamic，目标表达式为 `concat("https://fomo9527.top", http.request.uri.path)`，状态码 `301`，开启 **Preserve query string**。

发布规则后按上表验证，排查与现有重定向、Always Use HTTPS、Worker 等配置的冲突或循环。[Cloudflare 官方配置说明](https://developers.cloudflare.com/rules/url-forwarding/single-redirects/create-dashboard/)

`_redirects` 不支持按域名或协议匹配，HTTP 与 www 的统一仍需配置上面两条 Cloudflare Redirect Rules；不能用一条 `/*` 跳转到主域来代替，否则会让主域自己循环跳转。当前代码已补充 `404.html`；部署后检查随机不存在的路径确实返回 `404`，不要设置 `/* → /index.html 200`。本次修改前的线上无效路径已返回 `404`。[Cloudflare Pages 路由与 404 说明](https://developers.cloudflare.com/pages/configuration/serving-pages/)

### 可选：Nginx

如果由自己的 Nginx 提供静态文件，可参考以下配置。替换站点目录与证书路径；证书必须覆盖两个域名。若前面还有 Cloudflare，请使用正确的源站 HTTPS 配置，避免 HTTP 回源触发循环。应用前先执行 `nginx -t`。

```nginx
server {
    listen 80;
    server_name fomo9527.top www.fomo9527.top;

    if ($request_uri ~ "^/index\.html(?:\?|$)") {
        return 301 https://fomo9527.top/$is_args$args;
    }
    return 301 https://fomo9527.top$request_uri;
}

server {
    listen 443 ssl;
    server_name fomo9527.top www.fomo9527.top;
    ssl_certificate /etc/ssl/fomo9527.top/fullchain.pem;
    ssl_certificate_key /etc/ssl/fomo9527.top/privkey.pem;

    root /var/www/shop;
    index index.html;

    # 检查原始请求，避免首页内部解析为 index.html 后再次跳转。
    if ($request_uri ~ "^/index\.html(?:\?|$)") {
        return 301 https://fomo9527.top/$is_args$args;
    }
    if ($host = www.fomo9527.top) {
        return 301 https://fomo9527.top$request_uri;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
```

## 上线验证与维护

2026-10-20 已通过 GitHub `main` 发布本轮静态资源，发布时 Cloudflare 版本 `e40393b9` 显示就绪、流量 100%。线上复查：首页、新 `/chatgpt/` 页面、CSS、robots 和新版 sitemap 均返回 `200`；新页面 self-canonical、首页内链和 sitemap 两个网址已确认；HTTP 与 www 返回 `301` 到 HTTPS 主域并保留路径和查询参数，显式详情页 `index.html` 返回 `301`，无效路径及非公开 README/脚本返回 `404`。Search Console 正式报告确认首页已收录；新页面在 16:50 实时测试显示“网址可编入 Google 索引”，检测到 1 项有效面包屑内容，尚未确认正式收录。其“请求编入索引”操作因无法连接 reCAPTCHA 服务失败，未确认提交成功，避免反复点击。随后成功提交更新后的 sitemap；Google 后台显示提交和上次读取日期均为 10 月 20 日、状态成功、已发现网页为 **2**，不等同于两个页面均已收录。

同日访问检查中，PowerShell 请求返回 `200`，Python 默认客户端返回 Cloudflare `403 / 1010`。这表明存在客户端访问限制，不能据此认定真实搜索爬虫被拦。需在 Cloudflare **Security → Events** 中按请求时间、路径与命中规则核查，并结合站长平台抓取报告及真实爬虫身份确认；仅针对误拦规则调整，避免为 SEO 关闭所有安全防护。[Cloudflare 1010 说明](https://developers.cloudflare.com/support/troubleshooting/http-status-codes/cloudflare-1xxx-errors/error-1010/)

- 检查普通浏览器与搜索引擎实际抓取均能直接取得页面及静态资源；无登录、`noindex` 响应头或 WAF/机器人挑战阻挡。仅更换 User-Agent 无法证明真实 Googlebot 可访问，应结合站长平台 URL 检查和服务器日志确认。
- 检查上表中的状态码、Location 和查询参数，确认无循环；确认首页 HTML 的 canonical 为 `https://fomo9527.top/`。可用 `curl.exe -I "https://www.fomo9527.top/index.html?utm_source=test"` 检查首跳，再用 `curl.exe -IL "https://www.fomo9527.top/index.html?utm_source=test"` 检查完整链路。
- 商品价格、时长、供货、交付或售后规则变更时，同步更新正文、标题/描述和相关结构化数据，并核对购买页，保持信息一致。不要加入没有依据的销量、评价或承诺。
- sitemap 当前列出首页和 `/chatgpt/` 两个规范网址；后续新增独立可索引页面时再加入完整规范 URL。没有可靠修改时间时不填 `lastmod`，不机械刷新时间。
- 在站长平台持续观察抓取、索引、搜索词、点击和展示数据。提交 sitemap 或添加结构化数据不保证收录、排名或富结果展示。

### 四个平台验证与提交

方法核验日期：**2026-10-16**。以下依据当前可访问的官方公开文档及提交入口；公开页面访问成功不代表已核实登录后的账号权限，也不代表规则于当天发布。实际后台功能、验证值与提交额度以当前账号为准。

先确保正式首页与 `https://fomo9527.top/sitemap.xml` 已部署且公开可访问。验证文件、HTML 标签或 DNS 记录必须使用各平台为当前账号实际生成的值，验证成功后保留；不要使用示例验证码。

| 平台 | 验证与提交步骤 | 后续检查 |
| --- | --- | --- |
| Google | 在 [Search Console](https://search.google.com/search-console/) 添加 `fomo9527.top` 域名资源，按平台给出的 DNS 记录完成[所有权验证](https://support.google.com/webmasters/answer/9008080?hl=zh-Hans)，可覆盖 www 与协议变体。在 Sitemaps 中提交 `https://fomo9527.top/sitemap.xml`；首页也可用 URL 检查中的“请求编入索引”。 | 用 URL 检查确认抓取、索引状态及 Google 选择的规范网址，再从效果报告观察查询词展示和点击。[抓取请求说明](https://developers.google.com/search/docs/crawling-indexing/ask-google-to-recrawl) |
| Bing | 登录 [Bing Webmaster Tools](https://www.bing.com/webmasters/)，添加 `https://fomo9527.top/`，按后台提供的方式验证；若 Google 已验证，也可按提示从 Search Console 导入。在 Sitemaps 中提交 `https://fomo9527.top/sitemap.xml`。 | 查看 sitemap 处理结果、URL 检查及搜索表现。[入门说明](https://www.bing.com/webmasters/help/getting-started-checklist-66a806de)、[Sitemaps 说明](https://www.bing.com/webmasters/help/sitemaps-3b5cf6ed) |
| 百度 | 在[站点管理](https://ziyuan.baidu.com/site/index)添加正式站点，按登录后实际提供的方式验证。进入[普通收录](https://ziyuan.baidu.com/linksubmit/index)，选择已验证站点提交首页链接；若账号当前开放 sitemap 入口，再提交 `https://fomo9527.top/sitemap.xml`。 | 检查抓取诊断、抓取异常、Robots、索引量及流量与关键词。普通收录帮助发现网址，不保证收录；提交方式和权限以当前账号为准。 |
| 搜狗 | 登录[搜狗搜索资源平台](https://zhanzhang.sogou.com/)，在“用户中心 → 网站管理”添加站点，按[验证帮助](https://zhanzhang.sogou.com/index.php/help/siteVerify)完成文件或 HTML 标签验证；部分功能还需资质审核。在[资源收录](https://zhanzhang.sogou.com/index.php/sitelink/index)提交 `https://fomo9527.top/`，避免重复提交。 | 当前资源收录入口明确**仅支持页面 URL，不支持 sitemap 文件**，不要将 XML 文件作为页面提交。观察收录索引、抓取及关键词数据。公开入口本次可访问，登录后的功能与资质要求以实际账号为准。 |

### IndexNow 更新通知

Bing 的[当前网址提交指南](https://www.bing.com/webmasters/help/URL-Submission-62f2860b)优先推荐 IndexNow。可优先在 Cloudflare 域名的 **Caching → Configuration → Crawler Hints** 开启原生通知；官方文档列明免费套餐可用。需要登录域名后台操作，当前未确认是否已开启。[Cloudflare Crawler Hints](https://developers.cloudflare.com/cache/advanced-configuration/crawler-hints/)

若未使用原生通知，项目已提供一次性手动通知入口：

1. 将 `indexnow-key.txt` 与本版首页一起部署，确认 `https://fomo9527.top/indexnow-key.txt` 返回文件中的验证值。该文件是协议要求公开提供的所有权验证文件，不是 Cloudflare 或站长平台账号凭证；不要删除或改写为 HTML。
2. 在项目根目录预览：`powershell -NoProfile -File .\scripts\submit-indexnow.ps1`。默认只输出待提交内容，不请求网络。
3. 页面实际更新且部署完成后执行：`powershell -NoProfile -File .\scripts\submit-indexnow.ps1 -Submit`。脚本读取 sitemap 中的规范网址，先校验线上验证文件及每页的状态码、self-canonical 和 noindex 指令，再一次性向 `https://api.indexnow.org/indexnow` 通知这些页面；任何页面未部署、发生跳转或校验不通过则停止。

Cloudflare Crawler Hints 与手动脚本选择一种即可；无需定时或反复提交未变化的页面。当前脚本从 sitemap 读取首页与 `/chatgpt/`；大站或部分页面变更时应只通知实际变化的网址，不应按此小站用法反复全量提交。HTTP `200` 只表示接收，`202` 表示收到但验证密钥待处理，都不代表已抓取、收录或获得排名；HTTP `403/422/429` 等错误先按返回原因排查。IndexNow 仅面向参与协议的引擎，不是 Google、百度、搜狗全部通用的提交入口。2026-10-20 正式部署并通过线上预检后，已一次性通知这两个发生变化的网址；返回 **HTTP 202，验证密钥待处理**，尚未确认抓取或收录。[IndexNow 官方协议](https://www.indexnow.org/documentation)、[官方 FAQ](https://www.indexnow.org/faq)

提交后分别记录各平台的验证结果、提交时间、抓取/索引状态及上述目标词的展示和点击。HTTP `200`、本地结构检查、伪装爬虫 User-Agent 的请求成功，都不能作为真实爬虫已抓取或搜索已收录的证据；以平台报告和经身份核实的服务器爬虫日志交叉确认。抓取、索引和关键词展示是不同阶段，不重复提交来催促排名。搜狗关于文本内容、页面标题和原创信息的要求见[官方站长指南](https://help.sogou.com/guide.html)。

SEO 依据：[Google 规范网址与永久重定向](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls)、[Google sitemap 创建与提交](https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap)、[Google robots.txt 创建规则](https://developers.google.com/crawling/docs/robots-txt/create-robots-txt)。
