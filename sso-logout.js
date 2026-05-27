(function () {
  function inject() {
    if (document.getElementById('sso-logout-btn')) return true;

    var header = document.querySelector('header.ant-layout-header');
    if (!header) return false;

    header.style.position = 'relative';
    header.style.paddingRight = '70px';

    var style = document.createElement('style');
    style.id = 'sso-logout-style';
    style.innerHTML = '#sso-logout-btn:hover{border:1px solid #ffffff !important;}';
    document.head.appendChild(style);

    var btn = document.createElement('a');
    btn.id = 'sso-logout-btn';
    btn.title = 'Sign Out';
    btn.style.cssText = 'position:absolute;top:9px;right:12px;z-index:999999;display:inline-flex;align-items:center;justify-content:center;height:31px;width:48px;cursor:pointer;color:#fff;text-decoration:none;border:1px solid rgba(255,255,255,.25);border-radius:4px;background:#3f3d66;';
    btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>';

    btn.onclick = function (e) {
      e.preventDefault();
      var keycloakLogout = 'https://auth.bluefunda.com/realms/trm/protocol/openid-connect/logout'
        + '?client_id=cube'
        + '&post_logout_redirect_uri=' + encodeURIComponent('https://analytics.bluefunda.com/');
      window.location.href = '/oauth2/sign_out?rd=' + encodeURIComponent(keycloakLogout);
    };

    header.appendChild(btn);
    return true;
  }

  if (!inject()) {
    var observer = new MutationObserver(function () {
      if (inject()) observer.disconnect();
    });
    observer.observe(document.body, { childList: true, subtree: true });
  }
})();
