<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yasahaba Wifi — Internet Cepat & Stabil Sejak 2021</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
    <style>
        /* ===== RESET & BASE ===== */
        * { margin: 0; padding: 0; box-sizing: border-box; 
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            -webkit-font-smoothing: antialiased; }

        /* ===== THEME VARIABLES ===== */
        :root {
            --radius: 20px;
            --radius-sm: 14px;
            
            /* Brand colors */
            --primary: #6366f1;
            --primary-2: #8b5cf6;
            --primary-glow: rgba(99,102,241,0.4);
            --cyan: #22d3ee;
            --pink: #ec4899;
            --amber: #fbbf24;
            --green: #10b981;
        }

        /* ===== LIGHT MODE (Siang) ===== */
        html[data-theme="light"] {
            --bg: #eef1f8;
            --bg-2: #ffffff;
            --surface: #ffffff;
            --surface-hover: #f7f8fc;
            --border: rgba(15,23,42,0.12);
            --border-soft: rgba(15,23,42,0.08);
            --text: #0a0f1f;
            --sub: #475569;
            --sub-2: #64748b;
            --nav-bg: rgba(238, 241, 248, 0.85);
            --card-shadow: 0 2px 8px rgba(15,23,42,0.06), 0 8px 24px rgba(15,23,42,0.04);
            --card-shadow-hover: 0 8px 24px rgba(99,102,241,0.15), 0 20px 48px rgba(15,23,42,0.08);
            --bg-glow-1: rgba(99,102,241,0.08);
            --bg-glow-2: rgba(236,72,153,0.05);
            --bg-glow-3: rgba(34,211,238,0.05);
            --grid-color: rgba(15,23,42,0.04);
            --input-bg: #ffffff;
            --select-option-bg: #ffffff;
        }

        /* ===== DARK MODE (Malam) ===== */
        html[data-theme="dark"] {
            --bg: #08080f;
            --bg-2: #0d0d1a;
            --surface: rgba(255,255,255,0.04);
            --surface-hover: rgba(255,255,255,0.07);
            --border: rgba(255,255,255,0.08);
            --border-soft: rgba(255,255,255,0.05);
            --text: #f5f6fa;
            --sub: #8b8fa3;
            --sub-2: #5e6278;
            --nav-bg: rgba(8, 8, 15, 0.75);
            --card-shadow: 0 4px 20px rgba(0,0,0,0.2);
            --card-shadow-hover: 0 20px 40px rgba(99,102,241,0.15);
            --bg-glow-1: rgba(99,102,241,0.15);
            --bg-glow-2: rgba(236,72,153,0.1);
            --bg-glow-3: rgba(34,211,238,0.08);
            --grid-color: rgba(255,255,255,0.02);
            --input-bg: #0d0d1a;
            --select-option-bg: #0d0d1a;
        }

        /* ===== SMOOTH THEME TRANSITION ===== */
        html, body, header, .card, .stat-item, .service-card, .paket-card,
        input, select, textarea, .contact-item, .btn-ghost, .service-tag,
        footer, .hero-badge, .section-tag, .theme-toggle {
            transition: background-color 0.4s ease, 
                        border-color 0.4s ease, 
                        color 0.4s ease,
                        box-shadow 0.4s ease;
        }

        html { scroll-behavior: smooth; }

        body {
            background: var(--bg);
            color: var(--text);
            line-height: 1.5;
            font-size: 14px;
            min-height: 100vh;
            overflow-x: hidden;
            position: relative;
        }

        /* ===== BACKGROUND GLOW ===== */
        body::before {
            content: '';
            position: fixed;
            inset: 0;
            z-index: -2;
            background:
                radial-gradient(ellipse 800px 600px at 20% -10%, var(--bg-glow-1), transparent 60%),
                radial-gradient(ellipse 700px 500px at 100% 20%, var(--bg-glow-2), transparent 60%),
                radial-gradient(ellipse 600px 500px at 0% 80%, var(--bg-glow-3), transparent 60%),
                var(--bg);
            transition: background 0.4s ease;
        }

        /* Subtle grid overlay */
        body::after {
            content: '';
            position: fixed;
            inset: 0;
            z-index: -1;
            background-image:
                linear-gradient(var(--grid-color) 1px, transparent 1px),
                linear-gradient(90deg, var(--grid-color) 1px, transparent 1px);
            background-size: 50px 50px;
            mask-image: radial-gradient(ellipse at center, black 20%, transparent 75%);
            -webkit-mask-image: radial-gradient(ellipse at center, black 20%, transparent 75%);
            pointer-events: none;
            transition: background-image 0.4s ease;
        }

        a { text-decoration: none; color: inherit; }
        ::selection { background: var(--primary); color: #fff; }
        h1, h2, h3 { font-family: 'Space Grotesk', 'Inter', sans-serif; }

        /* ===== NAVBAR ===== */
        header {
            position: sticky;
            top: 0;
            z-index: 100;
            background: var(--nav-bg);
            backdrop-filter: blur(20px) saturate(180%);
            -webkit-backdrop-filter: blur(20px) saturate(180%);
            border-bottom: 1px solid var(--border-soft);
        }
        .nav-inner {
            max-width: 1180px;
            margin: 0 auto;
            padding: 14px 22px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .brand { display: flex; align-items: center; gap: 10px; }
        .logo-mark {
            width: 34px; height: 34px; border-radius: 10px;
            background: linear-gradient(135deg, var(--primary), var(--primary-2));
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 4px 16px var(--primary-glow);
        }
        .logo-mark svg { width: 18px; height: 18px; color: #fff; }
        .brand-text { display: flex; flex-direction: column; gap: 0; }
        .logo { font-family: 'Space Grotesk', sans-serif; font-size: 16px; font-weight: 700; letter-spacing: -0.3px; color: var(--text); }
        .brand .sub { color: var(--sub-2); font-size: 10.5px; font-weight: 500; letter-spacing: 0.2px; }
        .nav-right { display: flex; align-items: center; gap: 6px; }
        .nav-links { display: flex; align-items: center; gap: 2px; }
        .nav-links a {
            color: var(--sub); font-weight: 600; font-size: 13px;
            padding: 8px 14px; border-radius: 10px; transition: all 0.2s ease;
        }
        .nav-links a:hover { color: var(--text); background: var(--surface-hover); }
        .nav-cta {
            background: linear-gradient(135deg, var(--primary), var(--primary-2)) !important;
            color: #fff !important; margin-left: 8px; box-shadow: 0 4px 14px var(--primary-glow);
        }
        .nav-cta:hover { box-shadow: 0 6px 20px var(--primary-glow) !important; transform: translateY(-1px); }

        /* ===== THEME TOGGLE ===== */
        .theme-toggle {
            width: 38px; height: 38px; border-radius: 10px;
            background: var(--surface); border: 1px solid var(--border);
            color: var(--text); cursor: pointer; display: flex;
            align-items: center; justify-content: center; position: relative;
            margin-left: 8px; overflow: hidden;
        }
        .theme-toggle:hover { background: var(--surface-hover); border-color: var(--primary); transform: translateY(-1px); }
        .theme-toggle svg { width: 18px; height: 18px; position: absolute; transition: opacity 0.4s ease, transform 0.4s ease; }
        .theme-toggle .icon-sun { opacity: 0; transform: rotate(90deg) scale(0.5); color: var(--amber); }
        .theme-toggle .icon-moon { opacity: 1; transform: rotate(0deg) scale(1); color: var(--primary); }
        html[data-theme="light"] .theme-toggle .icon-sun { opacity: 1; transform: rotate(0deg) scale(1); }
        html[data-theme="light"] .theme-toggle .icon-moon { opacity: 0; transform: rotate(-90deg) scale(0.5); }

        /* ===== HERO ===== */
        .hero { padding: 80px 22px 60px; max-width: 1180px; margin: 0 auto; position: relative; }
        .hero-badge {
            display: inline-flex; align-items: center; gap: 8px;
            background: rgba(16,185,129,0.1); border: 1px solid rgba(16,185,129,0.3);
            color: #047857; padding: 7px 14px; border-radius: 999px;
            font-size: 12px; font-weight: 700; margin-bottom: 24px;
        }
        html[data-theme="dark"] .hero-badge { background: rgba(16,185,129,0.08); border-color: rgba(16,185,129,0.2); color: var(--green); }
        .badge-dot { width: 6px; height: 6px; background: #10b981; border-radius: 50%; position: relative; animation: blink 1.8s infinite; }
        .badge-dot::after { content: ''; position: absolute; inset: 0; background: #10b981; border-radius: 50%; animation: pulseRing 2s ease-out infinite; }
        @keyframes pulseRing { 0% { transform: scale(1); opacity: 1; } 100% { transform: scale(3); opacity: 0; } }
        @keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.4; } }

        .hero h1 { font-size: clamp(30px, 5.5vw, 52px); font-weight: 700; line-height: 1.08; letter-spacing: -1.5px; margin-bottom: 20px; color: var(--text); max-width: 780px; }
        .hero h1 .grad {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-2) 50%, var(--pink) 100%);
            background-size: 200% 200%; -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; animation: gradientShift 5s ease infinite;
        }
        @keyframes gradientShift { 0%, 100% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } }
        .hero p { color: var(--sub); font-size: 15.5px; line-height: 1.65; max-width: 540px; margin-bottom: 32px; font-weight: 500; }
        .hero-buttons { display: flex; gap: 10px; flex-wrap: wrap; }

        /* ===== BUTTONS ===== */
        .btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px;
            padding: 13px 24px; border-radius: var(--radius-sm); font-weight: 600; font-size: 13.5px;
            cursor: pointer; border: none; transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            font-family: inherit; position: relative; overflow: hidden;
        }
        .btn svg { width: 16px; height: 16px; }
        .btn-primary { background: linear-gradient(135deg, var(--primary), var(--primary-2)); color: #fff; box-shadow: 0 6px 20px var(--primary-glow); }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 10px 28px rgba(139,92,246,0.5); }
        .btn-ghost { background: var(--surface); color: var(--text); border: 1px solid var(--border); font-weight: 600; }
        html[data-theme="light"] .btn-ghost { background: #ffffff; border-color: rgba(15,23,42,0.12); }
        html[data-theme="light"] .btn-ghost:hover { border-color: var(--primary); background: #f8f9fc; }
        .btn-ghost:hover { background: var(--surface-hover); border-color: rgba(99,102,241,0.3); transform: translateY(-2px); }

        /* ===== STATS ===== */
        .stats { max-width: 1180px; margin: 50px auto 0; display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; padding: 0 22px; }
        .stat-item { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 22px 16px; text-align: center; transition: all 0.25s ease; position: relative; overflow: hidden; box-shadow: var(--card-shadow); }
        .stat-item::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 2px; background: linear-gradient(90deg, var(--primary), var(--primary-2), var(--pink)); transform: scaleX(0); transform-origin: left; transition: transform 0.4s ease; }
        .stat-item:hover::before { transform: scaleX(1); }
        .stat-item:hover { border-color: rgba(139,92,246,0.3); background: var(--surface-hover); }
        .stat-value { font-family: 'Space Grotesk', sans-serif; font-size: 24px; font-weight: 700; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-2) 100%); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; letter-spacing: -0.5px; line-height: 1.2; }
        .stat-label { font-size: 11px; color: var(--sub); margin-top: 6px; text-transform: uppercase; letter-spacing: 1.2px; font-weight: 700; }

        /* ===== SECTION ===== */
        section { padding: 80px 22px; max-width: 1180px; margin: 0 auto; }
        .section-header { margin-bottom: 36px; max-width: 640px; }
        .section-tag { display: inline-block; background: rgba(99,102,241,0.12); color: #4f46e5; padding: 5px 12px; border-radius: 999px; font-size: 11px; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; margin-bottom: 14px; border: 1px solid rgba(99,102,241,0.25); }
        html[data-theme="dark"] .section-tag { background: rgba(99,102,241,0.1); color: var(--primary); border-color: rgba(99,102,241,0.2); }
        .section-title { font-size: clamp(24px, 3.8vw, 34px); font-weight: 700; letter-spacing: -0.8px; color: var(--text); margin-bottom: 10px; line-height: 1.15; }
        .section-subtitle { color: var(--sub); font-size: 14.5px; line-height: 1.6; font-weight: 500; }

        /* ===== SERVICES ===== */
        .services-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; }
        .service-card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 28px 24px; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); position: relative; overflow: hidden; box-shadow: var(--card-shadow); }
        .service-card::before { content: ''; position: absolute; inset: 0; background: radial-gradient(400px circle at var(--mouse-x, 50%) var(--mouse-y, 50%), rgba(139,92,246,0.08), transparent 40%); opacity: 0; transition: opacity 0.4s ease; pointer-events: none; }
        .service-card:hover::before { opacity: 1; }
        .service-card:hover { border-color: rgba(139,92,246,0.4); background: var(--surface-hover); transform: translateY(-4px); box-shadow: var(--card-shadow-hover); }
        .service-icon { width: 52px; height: 52px; border-radius: 14px; display: flex; align-items: center; justify-content: center; margin-bottom: 20px; transition: transform 0.4s ease; position: relative; }
        .service-card:hover .service-icon { transform: scale(1.08) rotate(-5deg); }
        .service-icon svg { width: 24px; height: 24px; color: #fff; }
        .icon-indigo { background: linear-gradient(135deg, #6366f1, #4f46e5); box-shadow: 0 8px 24px rgba(99,102,241,0.35); }
        .icon-cyan { background: linear-gradient(135deg, #22d3ee, #06b6d4); box-shadow: 0 8px 24px rgba(34,211,238,0.35); }
        .icon-pink { background: linear-gradient(135deg, #ec4899, #db2777); box-shadow: 0 8px 24px rgba(236,72,153,0.35); }
        .service-card h3 { font-size: 16px; font-weight: 700; color: var(--text); margin-bottom: 8px; letter-spacing: -0.2px; }
        .service-card p { color: var(--sub); font-size: 13.5px; line-height: 1.6; font-weight: 500; }
        .service-tag { display: inline-flex; align-items: center; gap: 5px; margin-top: 16px; background: var(--surface-hover); border: 1px solid var(--border); color: var(--sub); padding: 5px 11px; border-radius: 8px; font-size: 11px; font-weight: 700; }
        .service-tag .dot { width: 5px; height: 5px; border-radius: 50%; }

        /* ===== PACKAGES (SPLIT CATEGORY) ===== */
        .paket-kategori { margin-bottom: 50px; }
        .kategori-header { margin-bottom: 24px; }
        .kategori-title { font-size: 22px; font-weight: 700; color: var(--text); margin-bottom: 6px; display: flex; align-items: center; gap: 10px; }
        .kategori-desc { color: var(--sub); font-size: 14px; font-weight: 500; line-height: 1.6; max-width: 700px; padding-left: 12px; border-left: 3px solid var(--primary); }

        .packages-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(290px, 1fr)); gap: 16px; }
        .paket-card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 30px 26px; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); display: flex; flex-direction: column; position: relative; overflow: hidden; box-shadow: var(--card-shadow); }
        .paket-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px; background: linear-gradient(90deg, var(--primary), var(--primary-2), var(--pink)); transform: scaleX(0); transform-origin: left; transition: transform 0.5s ease; }
        .paket-card:hover::before { transform: scaleX(1); }
        .paket-card:hover { border-color: rgba(139,92,246,0.4); background: var(--surface-hover); transform: translateY(-4px); box-shadow: var(--card-shadow-hover); }
        .paket-card.featured { border-color: rgba(139,92,246,0.5); background: linear-gradient(180deg, rgba(139,92,246,0.08), rgba(99,102,241,0.03)); }
        html[data-theme="light"] .paket-card.featured { background: linear-gradient(180deg, rgba(139,92,246,0.06), rgba(99,102,241,0.02)); }
        .featured-badge { position: absolute; top: 16px; right: 16px; background: linear-gradient(135deg, var(--amber), #f59e0b); color: #1a1a2e; padding: 5px 11px; border-radius: 999px; font-size: 10.5px; font-weight: 800; letter-spacing: 0.5px; text-transform: uppercase; box-shadow: 0 4px 12px rgba(251,191,36,0.3); }
        .paket-name { font-size: 16px; font-weight: 700; color: var(--text); margin-bottom: 10px; letter-spacing: -0.3px; }
        .paket-speed { display: inline-flex; align-items: center; gap: 6px; font-size: 12px; color: #0891b2; margin-bottom: 18px; font-weight: 700; padding: 4px 10px; background: rgba(34,211,238,0.1); border: 1px solid rgba(34,211,238,0.25); border-radius: 999px; width: fit-content; }
        html[data-theme="dark"] .paket-speed { color: var(--cyan); background: rgba(34,211,238,0.08); border-color: rgba(34,211,238,0.2); }
        .paket-speed svg { width: 12px; height: 12px; }
        .paket-price { font-family: 'Space Grotesk', sans-serif; font-size: 30px; font-weight: 700; color: var(--text); letter-spacing: -1.5px; line-height: 1; margin-bottom: 8px; }
        .paket-price .currency { font-size: 15px; color: var(--sub); font-weight: 600; margin-right: 2px; }
        .paket-price .period { font-size: 13px; color: var(--sub); font-weight: 600; letter-spacing: 0; }
        .paket-desc { color: var(--sub); font-size: 13.5px; line-height: 1.6; margin: 14px 0 22px; flex-grow: 1; font-weight: 500; }
        .paket-card .btn { width: 100%; }

        /* ===== KONTAK ===== */
        .contact-grid { display: grid; grid-template-columns: 1fr 1.1fr; gap: 20px; align-items: start; }
        .card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 26px; position: relative; overflow: hidden; box-shadow: var(--card-shadow); }
        .card-title { font-size: 15px; font-weight: 700; color: var(--text); margin-bottom: 6px; letter-spacing: -0.2px; }
        .card-desc { color: var(--sub); font-size: 13px; line-height: 1.6; margin-bottom: 18px; font-weight: 500; }
        .contact-item { display: flex; align-items: center; gap: 12px; padding: 13px; background: var(--surface-hover); border: 1px solid var(--border); border-radius: var(--radius-sm); margin-bottom: 8px; transition: all 0.2s ease; }
        .contact-item:hover { border-color: rgba(139,92,246,0.4); transform: translateX(3px); }
        .contact-item:last-of-type { margin-bottom: 0; }
        .contact-icon { width: 38px; height: 38px; border-radius: 10px; background: linear-gradient(135deg, rgba(99,102,241,0.15), rgba(139,92,246,0.15)); border: 1px solid rgba(139,92,246,0.3); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .contact-icon svg { width: 17px; height: 17px; color: var(--primary); }
        .contact-label { font-size: 10.5px; color: var(--sub-2); text-transform: uppercase; letter-spacing: 1px; font-weight: 700; }
        .contact-value { font-size: 13.5px; color: var(--text); font-weight: 700; }
        .wa-btn { display: flex; align-items: center; justify-content: center; gap: 8px; width: 100%; padding: 14px; margin-top: 16px; background: linear-gradient(135deg, #10b981, #059669); color: #fff; border-radius: var(--radius-sm); font-weight: 700; font-size: 13.5px; transition: all 0.25s ease; box-shadow: 0 6px 20px rgba(16,185,129,0.3); }
        .wa-btn:hover { transform: translateY(-2px); box-shadow: 0 10px 28px rgba(16,185,129,0.5); }
        .wa-btn svg { width: 18px; height: 18px; }

        /* ===== FORM ===== */
        .form-group { margin-bottom: 14px; }
        .form-group label { display: block; margin-bottom: 7px; font-size: 12px; font-weight: 700; color: var(--text); letter-spacing: 0.2px; }
        input, select, textarea { width: 100%; background: var(--input-bg); border: 1.5px solid var(--border); outline: none; padding: 13px 15px; border-radius: var(--radius-sm); color: var(--text); font-size: 13.5px; font-family: inherit; font-weight: 500; transition: all 0.2s ease; -webkit-appearance: none; appearance: none; }
        input::placeholder, textarea::placeholder { color: var(--sub-2); font-weight: 400; }
        input:focus, select:focus, textarea:focus { border-color: var(--primary); background: rgba(99,102,241,0.04); box-shadow: 0 0 0 4px rgba(99,102,241,0.1); }
        select { background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2364748b' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e"); background-repeat: no-repeat; background-position: right 15px center; padding-right: 40px; }
        select option { background: var(--select-option-bg); color: var(--text); }
        textarea { resize: vertical; min-height: 90px; }
        .btn-submit { width: 100%; margin-top: 6px; padding: 14px; }

        /* ===== ALERTS ===== */
        .alert, .error-box { padding: 13px 16px; border-radius: var(--radius-sm); margin-bottom: 16px; font-size: 13px; line-height: 1.5; border: 1px solid; display: flex; align-items: flex-start; gap: 10px; font-weight: 600; }
        .alert svg, .error-box svg { width: 18px; height: 18px; flex-shrink: 0; margin-top: 1px; }
        .alert { background: rgba(16,185,129,0.08); border-color: rgba(16,185,129,0.25); color: #6ee7b7; }
        .error-box { background: rgba(239,68,68,0.08); border-color: rgba(239,68,68,0.25); color: #fca5a5; }
        .error-box ul { margin-left: 16px; }
        html[data-theme="light"] .alert { color: #047857; }
        html[data-theme="light"] .error-box { color: #b91c1c; }

        /* ===== FOOTER ===== */
        footer { border-top: 1px solid var(--border-soft); padding: 44px 22px 32px; margin-top: 40px; position: relative; }
        footer::before { content: ''; position: absolute; top: -1px; left: 20%; right: 20%; height: 1px; background: linear-gradient(90deg, transparent, var(--primary), transparent); }
        .footer-inner { max-width: 1180px; margin: 0 auto; display: grid; grid-template-columns: 1.5fr 1fr 1fr; gap: 36px; margin-bottom: 30px; }
        .footer-brand .brand { margin-bottom: 12px; }
        .footer-brand p { color: var(--sub); font-size: 13px; line-height: 1.6; max-width: 320px; font-weight: 500; }
        .footer-col h4 { font-size: 11px; text-transform: uppercase; letter-spacing: 1.2px; color: var(--text); margin-bottom: 14px; font-weight: 700; }
        .footer-col a { display: block; color: var(--sub); font-size: 13px; padding: 5px 0; transition: all 0.2s ease; font-weight: 500; }
        .footer-col a:hover { color: var(--primary); transform: translateX(3px); }
        .footer-bottom { max-width: 1180px; margin: 0 auto; padding-top: 24px; border-top: 1px solid var(--border-soft); text-align: center; color: var(--sub); font-size: 12px; font-weight: 500; }
        .footer-bottom .heart { color: var(--pink); display: inline-block; animation: heartBeat 1.5s ease infinite; }
        @keyframes heartBeat { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.25); } }

        /* ===== UTILS ===== */
        .scroll-top { position: fixed; bottom: 24px; right: 24px; width: 44px; height: 44px; background: linear-gradient(135deg, var(--primary), var(--primary-2)); color: #fff; border: none; border-radius: 12px; cursor: pointer; opacity: 0; visibility: hidden; transition: all 0.3s ease; z-index: 99; display: flex; align-items: center; justify-content: center; box-shadow: 0 6px 20px var(--primary-glow); }
        .scroll-top svg { width: 18px; height: 18px; }
        .scroll-top.visible { opacity: 1; visibility: visible; }
        .scroll-top:hover { transform: translateY(-3px); box-shadow: 0 10px 28px var(--primary-glow); }
        .reveal { opacity: 0; transform: translateY(24px); transition: opacity 0.7s ease, transform 0.7s cubic-bezier(0.4, 0, 0.2, 1); }
        .reveal.visible { opacity: 1; transform: translateY(0); }
        
        .theme-toast { position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%) translateY(100px); background: var(--bg-2); border: 1px solid var(--border); color: var(--text); padding: 10px 18px; border-radius: 999px; font-size: 12.5px; font-weight: 700; box-shadow: 0 8px 30px rgba(0,0,0,0.15); display: flex; align-items: center; gap: 8px; z-index: 200; opacity: 0; transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); pointer-events: none; }
        html[data-theme="light"] .theme-toast { box-shadow: 0 8px 30px rgba(15,23,42,0.12); }
        .theme-toast.show { transform: translateX(-50%) translateY(0); opacity: 1; }
        .theme-toast svg { width: 14px; height: 14px; }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 800px) { .contact-grid { grid-template-columns: 1fr; } .stats { grid-template-columns: repeat(2, 1fr); } .footer-inner { grid-template-columns: 1fr 1fr; gap: 24px; } }
        @media (max-width: 600px) { .nav-links a:not(.nav-cta) { display: none; } .nav-inner { padding: 12px 16px; } .hero { padding: 55px 20px 40px; } section { padding: 55px 20px; } .stats { grid-template-columns: repeat(2, 1fr); padding: 0 20px; } .footer-inner { grid-template-columns: 1fr; } .hero h1 { letter-spacing: -0.8px; } .paket-price { font-size: 26px; } }
    </style>

    <!-- ===== ANTI-FLASH SCRIPT ===== -->
    <script>
        (function() {
            var saved = localStorage.getItem('jlinet-theme');
            if (!saved) {
                var hour = new Date().getHours();
                saved = (hour >= 6 && hour < 18) ? 'light' : 'dark';
            }
            document.documentElement.setAttribute('data-theme', saved);
        })();
    </script>
</head>
<body>

    <!-- NAVBAR -->
    <header>
        <div class="nav-inner">
            <a href="#" class="brand">
                <div class="logo-mark">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M5 12.55a11 11 0 0 1 14.08 0"/>
                        <path d="M1.42 9a16 16 0 0 1 21.16 0"/>
                        <path d="M8.53 16.11a6 6 0 0 1 6.95 0"/>
                        <line x1="12" y1="20" x2="12.01" y2="20"/>
                    </svg>
                </div>
                <div class="brand-text">
                    <div class="logo">Yasahaba Wifi</div>
                    <div class="sub">Internet Cepat & Stabil</div>
                </div>
            </a>
            <div class="nav-right">
                <nav class="nav-links">
                    <a href="#layanan">Layanan</a>
                    <a href="#paket">Paket</a>
                    <a href="#kontak">Kontak</a>
                    <a href="#kontak" class="nav-cta">Daftar</a>
                </nav>
                <button class="theme-toggle" id="themeToggle" aria-label="Ganti tema">
                    <svg class="icon-moon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
                    </svg>
                    <svg class="icon-sun" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="4"/>
                        <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"/>
                    </svg>
                </button>
            </div>
        </div>
    </header>

    <!-- HERO -->
    <div class="hero">
        <div class="hero-badge">
            <span class="badge-dot"></span>
            Melayani Pelanggan Sejak 2021
        </div>
        <h1>
            Internet <span class="grad">Ngebut</span>,<br>
            Tanpa Takut Putus
        </h1>
        <p>Koneksi fiber optic super stabil. Streaming lancar, gaming tanpa lag, kerja dari rumah tanpa drama buffering.</p>
        <div class="hero-buttons">
            <a href="#kontak" class="btn btn-primary">
                Daftar Sekarang
            </a>
            <a href="#paket" class="btn btn-ghost">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                Lihat Paket
            </a>
        </div>
    </div>

    <!-- STATS -->
    <div class="stats">
        <div class="stat-item">
            <div class="stat-value" data-count="100">0+</div>
            <div class="stat-label">Pelanggan</div>
        </div>
        <div class="stat-item">
            <div class="stat-value" data-count="99">0%</div>
            <div class="stat-label">Uptime</div>
        </div>
        <div class="stat-item">
            <div class="stat-value">DUKUNGAN</div>
            <div class="stat-label">Terjamin</div>
        </div>
        <div class="stat-item">
            <div class="stat-value">2021</div>
            <div class="stat-label">Sejak</div>
        </div>
    </div>

    <!-- LAYANAN -->
    <section id="layanan">
        <div class="section-header reveal">
            <span class="section-tag">Layanan</span>
            <h2 class="section-title">Solusi Internet Buat Semua Kebutuhan</h2>
            <p class="section-subtitle">Dari rumahan sampai voucher harian, semua ada. Pilih yang paling cocok buat kamu.</p>
        </div>

        <div class="services-grid">
            <div class="service-card reveal">
                <div class="service-icon icon-indigo">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                        <polyline points="9 22 9 12 15 12 15 22"/>
                    </svg>
                </div>
                <h3>Internet Rumahan</h3>
                <p>Koneksi fiber optic langsung ke rumah. Stabil 24 jam, cocok buat keluarga, streaming TV, dan smart home.</p>
                <span class="service-tag"><span class="dot" style="background:#6366f1"></span>Fiber Optic</span>
            </div>

            <div class="service-card reveal">
                <div class="service-icon icon-cyan">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M5 12.55a11 11 0 0 1 14.08 0"/>
                        <path d="M1.42 9a16 16 0 0 1 21.16 0"/>
                        <path d="M8.53 16.11a6 6 0 0 1 6.95 0"/>
                        <line x1="12" y1="20" x2="12.01" y2="20"/>
                    </svg>
                </div>
                <h3>Hotspot RT/RW</h3>
                <p>Solusi internet murah meriah buat satu tongkrongan atau area perumahan. Sinyal kuat, Jangkauan luas.</p>
                <span class="service-tag"><span class="dot" style="background:#22d3ee"></span>Jangkauan Luas</span>
            </div>

            <div class="service-card reveal">
                <div class="service-icon icon-pink">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M2 9a3 3 0 0 1 0 6v2a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-2a3 3 0 0 1 0-6V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2z"/>
                        <line x1="9" y1="9" x2="9" y2="15"/>
                        <line x1="15" y1="9" x2="15" y2="15"/>
                    </svg>
                </div>
                <h3>Voucher Harian</h3>
                <p>Beli voucher harian. Tinggal masukin kode, langsung gas internetan.</p>
                <span class="service-tag"><span class="dot" style="background:#ec4899"></span>Bayar Harian</span>
            </div>
        </div>
    </section>

    <!-- PAKET -->
    <section id="paket" style="padding-top: 0;">
        <div class="section-header reveal">
            <span class="section-tag">Paket Internet</span>
            <h2 class="section-title">Pilih Paket Sesuai Kebutuhan</h2>
            <p class="section-subtitle">Harga Bersahabat, kualitas premium.</p>
        </div>

        <!-- 1. KATEGORI RUMAHAN -->
        <div class="paket-kategori reveal">
            <div class="kategori-header">
                <h3 class="kategori-title">Paket Internet Rumahan</h3>
                <p class="kategori-desc">Pasang router di rumah, <strong>bebas kasih nama WiFi sendiri</strong>. Mau disambungin ke hape berapa aja atau Smart TV, bebas ngga ada batesan perangkat. Cocok buat sekeluarga.</p>
            </div>
            <div class="packages-grid">
                @foreach($packages->where('tipe_layanan', 'pppoe') as $paket)
                    <div class="paket-card {{ $loop->iteration === 2 ? 'featured' : '' }}">
                        @if($loop->iteration === 2)
                            <div class="featured-badge">🔥 Terpopuler</div>
                        @endif
                        <div class="paket-name">{{ $paket->nama_paket }}</div>
                        
                        <div class="paket-speed">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
                            </svg>
                            Up to {{ $paket->kecepatan_mbps }} Mbps
                        </div>
                        
                        <div class="paket-price">
                            <span class="currency">Rp</span>{{ number_format($paket->harga, 0, ',', '.') }}<span class="period">/bln</span>
                        </div>
                        <p class="paket-desc">{{ $paket->deskripsi }}</p>
                        <a href="#kontak" class="btn btn-primary">Pilih Paket Rumahan</a>
                    </div>
                @endforeach
            </div>
        </div>

        <!-- 2. KATEGORI HOTSPOT -->
        <div class="paket-kategori reveal" style="margin-top: 60px;">
            <div class="kategori-header">
                <h3 class="kategori-title">Paket Hotspot (Voucher)</h3>
                <p class="kategori-desc">Solusi anak kos atau tongkrongan. Beli voucher sekali, <strong>bisa nyambung dimana aja</strong> selama dapet sinyal WiFi dengan nama <strong>yasahaba.net</strong></p>
            </div>
            <div class="packages-grid">
                @foreach($packages->where('tipe_layanan', 'hotspot') as $paket)
                    <div class="paket-card {{ $loop->iteration === 2 ? 'featured' : '' }}">
                        @if($loop->iteration === 2)
                            <div class="featured-badge">🔥 Paling Laris</div>
                        @endif
                        <div class="paket-name">{{ $paket->nama_paket }}</div>
                        
                        <div class="paket-speed" style="color: #ec4899; background: rgba(236,72,153,0.1); border-color: rgba(236,72,153,0.25);">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="5" y="2" width="14" height="20" rx="2" ry="2"/>
                                <line x1="12" y1="18" x2="12.01" y2="18"/>
                            </svg>
                            Maksimal {{ $paket->limit_device }} Perangkat
                        </div>
                        
                        <div class="paket-price">
                            <span class="currency">Rp</span>{{ number_format($paket->harga, 0, ',', '.') }}<span class="period">/bln</span>
                        </div>
                        <p class="paket-desc">{{ $paket->deskripsi }}</p>
                        <a href="#kontak" class="btn btn-primary">Pilih Paket Hotspot</a>
                    </div>
                @endforeach
            </div>
        </div>
    </section>

    <!-- KONTAK -->
    <section id="kontak" style="padding-top: 0;">
        <div class="section-header reveal">
            <span class="section-tag">Hubungi Kami</span>
            <h2 class="section-title">Daftar atau Tanya Dulu, Bebas</h2>
            <p class="section-subtitle">Tim kita siap bantu 08:00 - 22:00 WIB. Respon cepat, no ribet.</p>
        </div>

        <div class="contact-grid">
            <!-- Info Kontak -->
            <div class="reveal">
                <div class="card">
                    <div class="card-title">Info Kontak</div>
                    <p class="card-desc">Cek dulu ketersediaan jaringan di area rumah sebelum daftar.</p>

                    <div class="contact-item">
                        <div class="contact-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
                                <circle cx="12" cy="10" r="3"/>
                            </svg>
                        </div>
                        <div>
                            <div class="contact-label">Kantor</div>
                            <div class="contact-value">Indramayu, Jawa Barat</div>
                        </div>
                    </div>

                    <div class="contact-item">
                        <div class="contact-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10"/>
                                <polyline points="12 6 12 12 16 14"/>
                            </svg>
                        </div>
                        <div>
                            <div class="contact-label">Jam Operasional</div>
                            <div class="contact-value">08:00 - 22:00 WIB</div>
                        </div>
                    </div>

                    <div class="contact-item">
                        <div class="contact-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
                            </svg>
                        </div>
                        <div>
                            <div class="contact-label">Berdiri Sejak</div>
                            <div class="contact-value">2021 — Sekarang</div>
                        </div>
                    </div>

                    <a href="https://wa.me/6281234567890?text=Halo%20Yasahaba%20Wifi,%20saya%20mau%20tanya%20soal%20pemasangan%20internet" target="_blank" class="wa-btn">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                        </svg>
                        Chat WhatsApp Admin
                    </a>
                </div>
            </div>

            <!-- Form -->
            <div class="reveal">
                <div class="card">
                    <div class="card-title">Form Pendaftaran Pelanggan Baru</div>
                    <p class="card-desc">Isi data, tim kami bakal langsung hubungi.</p>

                    @if(session('success'))
                        <div class="alert">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                                <polyline points="22 4 12 14.01 9 11.01"/>
                            </svg>
                            {{ session('success') }}
                        </div>
                    @endif

                    @if ($errors->any())
                        <div class="error-box">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10"/>
                                <line x1="12" y1="8" x2="12" y2="12"/>
                                <line x1="12" y1="16" x2="12.01" y2="16"/>
                            </svg>
                            <ul>
                                @foreach ($errors->all() as $error)
                                    <li>{{ $error }}</li>
                                @endforeach
                            </ul>
                        </div>
                    @endif

                    <form action="{{ route('pemasaran.daftar') }}" method="POST">
                        @csrf
                        <div class="form-group">
                            <label>Nama Lengkap</label>
                            <input type="text" name="nama_lengkap" value="{{ old('nama_lengkap') }}" required placeholder="Masukkan nama">
                        </div>

                        <div class="form-group">
                            <label>Nomor WhatsApp (Aktif)</label>
                            <input type="number" name="no_wa" value="{{ old('no_wa') }}" required placeholder="Contoh: 08123456789">
                        </div>

                        <div class="form-group">
                            <label>Alamat Pemasangan Lengkap</label>
                            <textarea name="alamat_pemasangan" rows="3" required placeholder="Jalan, RT/RW, Desa, Patokan Rumah">{{ old('alamat_pemasangan') }}</textarea>
                        </div>

                        <div class="form-group">
                            <label>Pilih Paket</label>
                            <select name="package_id" required>
                                <option value="">-- Pilih Paket Internet --</option>
                                
                                <optgroup label="Paket Rumahan">
                                    @foreach($packages->where('tipe_layanan', 'pppoe') as $paket)
                                        <option value="{{ $paket->id }}">{{ $paket->nama_paket }} (Rp {{ number_format($paket->harga, 0, ',', '.') }})</option>
                                    @endforeach
                                </optgroup>

                                <optgroup label="Paket Hotspot">
                                    @foreach($packages->where('tipe_layanan', 'hotspot') as $paket)
                                        <option value="{{ $paket->id }}">{{ $paket->nama_paket }} (Rp {{ number_format($paket->harga, 0, ',', '.') }})</option>
                                    @endforeach
                                </optgroup>
                            </select>
                        </div>

                        <button type="submit" class="btn btn-primary btn-submit">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:16px;height:16px;">
                                <line x1="22" y1="2" x2="11" y2="13"/>
                                <polygon points="22 2 15 22 11 13 2 9 22 2"/>
                            </svg>
                            Kirim Pendaftaran
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </section>

    <!-- FOOTER -->
    <footer>
        <div class="footer-inner">
            <div class="footer-brand">
                <a href="#" class="brand">
                    <div class="logo-mark">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M5 12.55a11 11 0 0 1 14.08 0"/>
                            <path d="M1.42 9a16 16 0 0 1 21.16 0"/>
                            <path d="M8.53 16.11a6 6 0 0 1 6.95 0"/>
                            <line x1="12" y1="20" x2="12.01" y2="20"/>
                        </svg>
                    </div>
                    <div class="brand-text">
                        <div class="logo">Yasahaba Wifi</div>
                        <div class="sub">Internet Cepat & Stabil</div>
                    </div>
                </a>
                <p>Internet lokal rasa sultan. Koneksi stabil, harga bersahabat, layanan premium sejak 2021.</p>
            </div>
            <div class="footer-col">
                <h4>Navigasi</h4>
                <a href="#layanan">Layanan</a>
                <a href="#paket">Paket Internet</a>
                <a href="#kontak">Daftar</a>
            </div>
            <div class="footer-col">
                <h4>Kontak</h4>
                <a href="#">Indramayu, Jabar</a>
                <a href="#">08:00 - 22:00 WIB</a>
                <a href="https://wa.me/6281234567890" target="_blank">WhatsApp Admin</a>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; {{ date('Y') }} Yasahaba Wifi. Supported By GesitNet</p>
        </div>
    </footer>

    <!-- SCROLL TOP -->
    <button class="scroll-top" id="scrollTop" aria-label="Scroll to top">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="19" x2="12" y2="5"/>
            <polyline points="5 12 12 5 19 12"/>
        </svg>
    </button>

    <!-- THEME TOAST -->
    <div class="theme-toast" id="themeToast">
        <svg id="themeToastIcon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></svg>
        <span id="themeToastText">Mode</span>
    </div>

    <script>
        // ============================================
        // THEME SYSTEM
        // ============================================
        (function() {
            var html = document.documentElement;
            var toggle = document.getElementById('themeToggle');
            var toast = document.getElementById('themeToast');
            var toastIcon = document.getElementById('themeToastIcon');
            var toastText = document.getElementById('themeToastText');
            var toastTimer;

            function getTimeBasedTheme() {
                var hour = new Date().getHours();
                return (hour >= 6 && hour < 18) ? 'light' : 'dark';
            }

            function applyTheme(theme, showToast) {
                html.setAttribute('data-theme', theme);
                
                if (showToast) {
                    var isLight = theme === 'light';
                    toastIcon.innerHTML = isLight 
                        ? '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"/>'
                        : '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>';
                    toastText.textContent = isLight ? 'Mode Siang ☀️' : 'Mode Malam 🌙';
                    
                    toast.classList.add('show');
                    clearTimeout(toastTimer);
                    toastTimer = setTimeout(function() {
                        toast.classList.remove('show');
                    }, 2000);
                }
            }

            var saved = localStorage.getItem('jlinet-theme');
            var currentTheme = saved || getTimeBasedTheme();
            applyTheme(currentTheme, false);

            toggle.addEventListener('click', function() {
                var current = html.getAttribute('data-theme');
                var next = current === 'dark' ? 'light' : 'dark';
                applyTheme(next, true);
                localStorage.setItem('jlinet-theme', next);
            });

            setInterval(function() {
                if (!localStorage.getItem('jlinet-theme')) {
                    var newTheme = getTimeBasedTheme();
                    if (html.getAttribute('data-theme') !== newTheme) {
                        applyTheme(newTheme, true);
                    }
                }
            }, 60000);
        })();

        // ===== SCROLL REVEAL =====
        const revealObs = new IntersectionObserver((entries) => {
            entries.forEach(e => {
                if (e.isIntersecting) e.target.classList.add('visible');
            });
        }, { threshold: 0.1, rootMargin: '0px 0px -60px 0px' });
        document.querySelectorAll('.reveal').forEach(el => revealObs.observe(el));

        // ===== SCROLL TOP =====
        const scrollTopBtn = document.getElementById('scrollTop');
        window.addEventListener('scroll', () => {
            if (window.scrollY > 400) scrollTopBtn.classList.add('visible');
            else scrollTopBtn.classList.remove('visible');
        });
        scrollTopBtn.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));

        // ===== COUNTER ANIMATION =====
        const counters = document.querySelectorAll('[data-count]');
        const counterObs = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting && !entry.target.dataset.done) {
                    entry.target.dataset.done = 'true';
                    const target = parseInt(entry.target.dataset.count);
                    const suffix = entry.target.textContent.replace(/[0-9]/g, '');
                    let current = 0;
                    const step = Math.max(1, Math.ceil(target / 40));
                    const tick = () => {
                        current += step;
                        if (current >= target) {
                            current = target;
                            entry.target.textContent = current + suffix;
                            return;
                        }
                        entry.target.textContent = current + suffix;
                        requestAnimationFrame(tick);
                    };
                    tick();
                }
            });
        }, { threshold: 0.5 });
        counters.forEach(c => counterObs.observe(c));

        // ===== SPOTLIGHT EFFECT =====
        document.querySelectorAll('.service-card').forEach(card => {
            card.addEventListener('mousemove', (e) => {
                const rect = card.getBoundingClientRect();
                card.style.setProperty('--mouse-x', (e.clientX - rect.left) + 'px');
                card.style.setProperty('--mouse-y', (e.clientY - rect.top) + 'px');
            });
        });

        // ===== SMOOTH SCROLL =====
        document.querySelectorAll('a[href^="#"]').forEach(a => {
            a.addEventListener('click', (e) => {
                const target = document.querySelector(a.getAttribute('href'));
                if (target) {
                    e.preventDefault();
                    const top = target.offsetTop - 70;
                    window.scrollTo({ top, behavior: 'smooth' });
                }
            });
        });
    </script>
</body>
</html>