<?php
/**
 * This file is part of Athene2.
 *
 * Copyright (c) 2013-2019 Serlo Education e.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
 * you may not use this file except in compliance with the License
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @copyright Copyright (c) 2013-2019 Serlo Education e.V.
 * @license   http://www.apache.org/licenses/LICENSE-2.0 Apache License 2.0
 * @link      https://github.com/serlo-org/athene2 for the canonical source repository
 */

$env = 'production';

$featureFlags = ${feature_flags};
$assets = [];

$services = [
    'editor_renderer' => '${editor_renderer_uri}',
    'legacy_editor_renderer' => '${legacy_editor_renderer_uri}',
    'hydra' => '${hydra_admin_uri}',
];

$db = [
    'host' => '${php_db_host}',
    'port' => '3306',
    'username' => '${database_username}',
    'password' => '${database_password}',
    'database' => 'serlo',
];

$recaptcha = [
    'key' => '${php_recaptcha_key}',
    'secret' => '${php_recaptcha_secret}',
];

$api_cache_options = [
    'account' => '${api_cache_account}',
    'namespace' => '${api_cache_namespace}',
    'token' => '${api_cache_token}',
];
$smtp_options = [
    'name' => 'smtp.eu.sparkpostmail.com',
    'host' => 'smtp.eu.sparkpostmail.com',
    'port' => 2525,
    'connection_class' => 'login',
    'connection_config' => [
        'username' => 'SMTP_Injection',
        'password' => '${php_smtp_password}',
    ],
];

$sentry_dsn = 'https://33d45de9758b4788b75a1466285da472@sentry.io/1518832';
$newsletter_key = '${php_newsletter_key}';

$cronjob_secret = '${cronjob_secret}';
$upload_secret = '${upload_secret}';
$mock_email = ${enable_mail_mock};

if (${php_tracking_switch}) {
    $code = <<<EOL
<script>
    (function(h,o,t,j,a,r){
        h.hj=h.hj||function(){(h.hj.q=h.hj.q||[]).push(arguments)};
        h._hjSettings={hjid:306257,hjsv:6};
        a=o.getElementsByTagName('head')[0];
        r=o.createElement('script');r.async=1;
        r.src=t+h._hjSettings.hjid+j+h._hjSettings.hjsv;
        a.appendChild(r);
    })(window,document,'https://static.hotjar.com/c/hotjar-','.js?sv=');
</script>
<script type="text/javascript">
    var disableStr='ga-disable-UA-20283862-3';if(document.cookie.indexOf(disableStr+'=true')>-1){window[disableStr]=true;}
        function gaOptout(){document.cookie=disableStr+'=true; expires=Thu, 31 Dec 2099 23:59:59 UTC; path=/';window[disableStr]=true;}
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
    ga('create', 'UA-20283862-3', 'serlo.org');ga('require', 'displayfeatures');ga('require', 'linkid', 'linkid.js');ga('set', 'anonymizeIp', true);ga('send', 'pageview');
    var visitTookTime = false;var didScroll = false;var bounceSent = false;var scrollCount=0;
    function testScroll(){++scrollCount;if(scrollCount==2){didScroll=true}sendNoBounce()}
    function timeElapsed(){visitTookTime=true;sendNoBounce()}
    function sendNoBounce(){if(didScroll&&visitTookTime&&!bounceSent){bounceSent=true;ga("send","event","no bounce","resist","User scrolled and spent 30 seconds on page.")}}
    setTimeout("timeElapsed()",3e4);
    window.addEventListener?window.addEventListener("scroll",testScroll,false):window.attachEvent("onScroll",testScroll);
</script>
<!-- Matomo -->
<script type="text/javascript">
  var _paq = window._paq || [];
  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u="//{matomo_tracking_domain}/";
    _paq.push(['setTrackerUrl', u+'matomo.php']);
    _paq.push(['setSiteId', '1']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
  })();
</script>
<!-- End Matomo Code -->
EOL;
    $tracking = [
        'instances' => [
            'deutsch' => [
                'code' => $code,
            ],
            'english' => [
                'code' => $code,
            ],
            'french' => [
                'code' => $code,
            ],
            'spanish' => [
                'code' => $code,
            ],
            'hindi' => [
                'code' => $code,
            ],
            'tamil' => [
                'code' => $code,
            ],
        ],
    ];
} else {
    $tracking = [];
}
