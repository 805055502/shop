# FOMO 介绍页

这是一个无构建步骤的静态落地页。介绍页规范网址为 `https://fomo9527.top/`，购买入口为外部站点 `https://wzyp.cn/shop/fomo`。

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

2026-10-16 上线前检查：两个 HTTPS 域名均返回首页 `200`，`/robots.txt` 与 `/sitemap.xml` 尚返回 `404`，测试的不存在路径返回 `404`。部署辅助文件后需重新验证，以上记录不代表新版本已上线。

- 检查普通浏览器与搜索引擎实际抓取均能直接取得页面及静态资源；无登录、`noindex` 响应头或 WAF/机器人挑战阻挡。仅更换 User-Agent 无法证明真实 Googlebot 可访问，应结合站长平台 URL 检查和服务器日志确认。
- 检查上表中的状态码、Location 和查询参数，确认无循环；确认首页 HTML 的 canonical 为 `https://fomo9527.top/`。可用 `curl.exe -I "https://www.fomo9527.top/index.html?utm_source=test"` 检查首跳，再用 `curl.exe -IL "https://www.fomo9527.top/index.html?utm_source=test"` 检查完整链路。
- 在 Google Search Console 验证 `fomo9527.top` 域名资源（DNS 验证可覆盖 www 与协议变体），提交 `https://fomo9527.top/sitemap.xml`；用 URL 检查确认实际抓取、索引状态及 Google 选定的规范网址。另在 Bing Webmaster Tools 和百度搜索资源平台验证站点，按账号当前开放的入口提交 sitemap 或首页链接；平台功能以实际可用为准。
- 商品价格、时长、供货、交付或售后规则变更时，同步更新正文、标题/描述和相关结构化数据，并核对购买页，保持信息一致。不要加入没有依据的销量、评价或承诺。
- sitemap 当前只列真实首页；新增独立可索引页面时再加入完整规范 URL。没有可靠修改时间时不填 `lastmod`，不机械刷新时间。
- 在站长平台持续观察抓取、索引、搜索词、点击和展示数据。提交 sitemap 或添加结构化数据不保证收录、排名或富结果展示。

SEO 依据：[Google 规范网址与永久重定向](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls)、[Google sitemap 创建与提交](https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap)、[Google robots.txt 创建规则](https://developers.google.com/crawling/docs/robots-txt/create-robots-txt)。
