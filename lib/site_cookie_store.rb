require 'action_dispatch/middleware/session/cookie_store'

class SiteCookieStore < ActionDispatch::Session::CookieStore
  private

  def site_key(request)
    suffix = request.get_header('jumpstart.site_key')
    suffix.present? ? "#{@key}_#{suffix}" : @key
  end

  def get_cookie(request)
    cookie_jar(request)[site_key(request)]
  end

  def set_cookie(request, session_id, cookie)
    cookie_jar(request)[site_key(request)] = cookie.merge(path: '/')
  end
end
