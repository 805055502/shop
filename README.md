# FOMO 介绍页

这是一个无构建步骤的静态落地页。介绍页规范网址为 `https://fomo9527.top/`，购买入口为外部站点 `https://wzyp.cn/shop/fomo`。

## 搜索目标

重点查询词为 **ChatGPT 代充、Claude 代充、Codex 代充、Grok 代充**，同时观察 ChatGPT、Claude、Codex、Grok 单品牌词。查询词不等于独立商品分类：本店 Codex 相关需求归入 ChatGPT 套餐，仅作关联关键词覆盖，不单独介绍或列为一种代充服务。页面服务说明按实际商品分为 ChatGPT、Claude、Gemini、Grok，服务内容、购买方式与实际店铺保持一致；不堆砌关键词、不添加不存在的商品。单品牌词意图较宽，不能承诺以介绍页覆盖所有相关搜索。

目标验收顺序为：**部署正式版本 → 四个平台完成真实所有权验证 → 提交网址 → 确认抓取与索引 → 观察目标查询词的展示和点击**。截至 2026-10-16，用户确认四个平台均尚未验证；以下是待执行步骤，不代表已经提交或收录。SEO 可以改善发现和理解页面的条件，不能保证所有词在所有引擎中出现或获得指定排名。

## 部署

将 `index.html`、`favicon.svg`、`robots.txt`、`sitemap.xml` 上传到站点根目录。首页及资源应通过 HTTPS 公开访问；`robots.txt` 应返回纯文本，`sitemap.xml` 应返回 XML，不能被重写为首页 HTML。README 无需作为公开页面部署。

页面 canonical、分享链接、结构化数据和 sitemap 使用同一主域。`www.fomo9527.top`、HTTP 访问及显式 `/index.html` 应由服务器或 Cloudflare 返回 **301 或 308**，统一到 HTTPS 非 www 地址。域名/协议跳转保留原路径及查询参数；只有 `/index.html` 合并为 `/`。例如：

| 请求 | 预期结果 |
| --- | --- |
| `https://fomo9527.top/` | `200` 首页 |
| `https://www.fomo9527.top/?utm_source=test` | `301/308` → `https://fomo9527.top/?utm_source=test` |
| `http://fomo9527.top/robots.txt` | `301/308` → `https://fomo9527.top/robots.txt` |
| `https://www.fomo9527.top/index.html?utm_source=test` | `301/308` → `https://fomo9527.top/?utm_source=test` |
| `https://fomo9527.top/not-a-real-page` | `404`，不能返回首页 `200` |

以下是待配置示例，不代表已修改线上部署。

### Cloudflare Redirect Rules

适用于通过 Cloudflare 代理的两个域名。先确认根域与 www 的 DNS 均已开启代理，且 HTTPS 证书覆盖两个域名。在域名控制台进入 **Rules → Redirect Rules**（新版界面可从 **Rules → Overview → Create rule → Redirect Rule** 进入），依次创建两条 Single Redirect 规则：

1. **合并显式首页**，放在下一条规则前。匹配条件使用自定义表达式：

   ```text
   (http.host in {"fomo9527.top" "www.fomo9527.top"} and http.request.uri.path eq "/index.html")
   ```

   动作选择 Static，目标 `https://fomo9527.top/`，状态码 `301`，开启 **Preserve query string**。

2. **统一 www 与 HTTP**，匹配条件：

   ```text
   (http.host eq "www.fomo9527.top" or (http.host eq "fomo9527.top" and http.request.scheme eq "http"))
   ```

   动作选择 Dynamic，目标表达式为 `concat("https://fomo9527.top", http.request.uri.path)`，状态码 `301`，开启 **Preserve query string**。

发布规则后按上表验证，排查与现有重定向、Always Use HTTPS、Worker 等配置的冲突或循环。[Cloudflare 官方配置说明](https://developers.cloudflare.com/rules/url-forwarding/single-redirects/create-dashboard/)

如果后续使用 Cloudflare Pages，留意它在缺少根目录 `404.html` 时默认启用 SPA fallback。这个项目没有前端路由；若出现不存在的路径返回首页 `200`，可在部署产物补充 `404.html`，或在实际 Worker/托管路由中返回真实 `404`，不要设置 `/* → /index.html 200`。本次检查中的线上无效路径已返回 `404`；仅凭 Cloudflare 响应头不能确定实际使用 Pages 或 Worker。[Cloudflare Pages 路由与 404 说明](https://developers.cloudflare.com/pages/configuration/serving-pages/)

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

2026-10-16 部署后复查：首页新版标题与 canonical 已生效，`/robots.txt` 与 `/sitemap.xml` 均返回 `200`，未发现首页 `noindex` 标签或响应头。HTTP 首页与 HTTPS www 首页仍直接返回 `200`，尚需按上面的规则统一跳转；真实爬虫抓取、平台索引状态及关键词效果仍待站长平台数据确认。

- 检查普通浏览器与搜索引擎实际抓取均能直接取得页面及静态资源；无登录、`noindex` 响应头或 WAF/机器人挑战阻挡。仅更换 User-Agent 无法证明真实 Googlebot 可访问，应结合站长平台 URL 检查和服务器日志确认。
- 检查上表中的状态码、Location 和查询参数，确认无循环；确认首页 HTML 的 canonical 为 `https://fomo9527.top/`。可用 `curl.exe -I "https://www.fomo9527.top/index.html?utm_source=test"` 检查首跳，再用 `curl.exe -IL "https://www.fomo9527.top/index.html?utm_source=test"` 检查完整链路。
- 商品价格、时长、供货、交付或售后规则变更时，同步更新正文、标题/描述和相关结构化数据，并核对购买页，保持信息一致。不要加入没有依据的销量、评价或承诺。
- sitemap 当前只列真实首页；新增独立可索引页面时再加入完整规范 URL。没有可靠修改时间时不填 `lastmod`，不机械刷新时间。
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

Bing 的[当前网址提交指南](https://www.bing.com/webmasters/help/URL-Submission-62f2860b)优先推荐 IndexNow。若后续接入更新通知，按 [IndexNow 官方协议](https://www.indexnow.org/documentation)部署所有权验证文件，在页面新增、更新或删除时通知变化的 URL；成功回执只表示网址已被接收，不代表已抓取、收录或获得排名。当前项目尚未接入或提交 IndexNow。

提交后分别记录各平台的验证结果、提交时间、抓取/索引状态及上述目标词的展示和点击。HTTP `200`、本地结构检查、伪装爬虫 User-Agent 的请求成功，都不能作为真实爬虫已抓取或搜索已收录的证据；以平台报告和经身份核实的服务器爬虫日志交叉确认。抓取、索引和关键词展示是不同阶段，不重复提交来催促排名。搜狗关于文本内容、页面标题和原创信息的要求见[官方站长指南](https://help.sogou.com/guide.html)。

SEO 依据：[Google 规范网址与永久重定向](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls)、[Google sitemap 创建与提交](https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap)、[Google robots.txt 创建规则](https://developers.google.com/crawling/docs/robots-txt/create-robots-txt)。
