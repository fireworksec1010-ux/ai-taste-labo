/* Shared illustrations for the English pages (line icons + hero art). No external images. */
(function(){
  "use strict";
  var P = {
    // food types
    nabe:   '<path d="M3 11h18v1.5a7.5 7.5 0 0 1-7.5 7.5h-3A7.5 7.5 0 0 1 3 12.5z"/><path d="M1.5 11h21"/><path d="M8 7.5c0-1.6 1.2-1.6 1.2-3.3M12 7.5c0-1.6 1.2-1.6 1.2-3.3M16 7.5c0-1.6 1.2-1.6 1.2-3.3"/>',
    soup:   '<path d="M3 11h18c0 4.4-4 8-9 8s-9-3.6-9-8z"/><path d="M8 21.5h8"/><path d="M10 7.5c0-1.6 1.2-1.6 1.2-3.3M14 7.5c0-1.6 1.2-1.6 1.2-3.3"/>',
    noodle: '<path d="M3 12h18c0 4.4-4 8-9 8s-9-3.6-9-8z"/><path d="M14.5 2.5L10.5 12M20 3.5l-6.5 8.5"/><path d="M6 15.5c1-1.4 2 1.4 3 0s2 1.4 3 0 2 1.4 3 0 2 1.4 3 0"/>',
    rice:   '<path d="M12 3c-2.2 0-8 10.5-8 13.8A3.2 3.2 0 0 0 7.2 20h9.6a3.2 3.2 0 0 0 3.2-3.2C20 13.5 14.2 3 12 3z"/><path d="M8.5 14h7v6h-7z"/>',
    dish:   '<ellipse cx="12" cy="15.5" rx="10" ry="4"/><path d="M5.5 13.5c2.2-3.2 7.6-3.2 9.8 0-2.2 3.2-7.6 3.2-9.8 0z"/><path d="M15.3 13.5l3.2-2.2v4.4z"/>',
    sweet:  '<path d="M3.5 20.5L20.5 3.5"/><circle cx="8" cy="16" r="2.7"/><circle cx="12" cy="12" r="2.7"/><circle cx="16" cy="8" r="2.7"/>',
    // site sections
    bowl:   '<path d="M3 12h18c0 4.4-4 8-9 8s-9-3.6-9-8z"/><path d="M6 12c0-3 2.7-5 6-5s6 2 6 5"/><path d="M15 3l-3 6M19 4l-4 6"/>',
    veggie: '<path d="M14 10L4.5 19.5c-.8.8-2-.4-1.2-1.2L13 8.5"/><path d="M13 8.5c1.5-1.5 3.5-1.5 4.5-.5s1 3-.5 4.5L14 10"/><path d="M17 7c1-2 3-3.5 4-3M17.5 6.5c.5-2 0-4-1-4.5M18 8c2 0 3.5 1 4 2"/>',
    ship:   '<path d="M3 15l2.2 4.5h13.6L21 15z"/><path d="M5 15V9h14v6"/><path d="M9 9V5h6v4"/><path d="M2 21.5c1.7 0 1.7-1 3.3-1s1.7 1 3.4 1 1.7-1 3.3-1 1.7 1 3.3 1 1.7-1 3.4-1 1.6 1 3.3 1"/>',
    box:    '<path d="M3 8l9-4 9 4v9l-9 4-9-4z"/><path d="M3 8l9 4 9-4M12 12v9"/><path d="M19 1.5v3M17.5 3h3"/>',
    chart:  '<path d="M3 21h18"/><path d="M5 21v-6M10 21V10M15 21v-8M20 21V5"/><path d="M4 11l5-5 5 4 6-7"/>',
    factory:'<path d="M2 21h20"/><path d="M3 21V11l5 3V11l5 3V11l5 3V5h3v16"/><path d="M7 18h2M12 18h2M17 18h2"/>',
    paper:  '<path d="M4 4h13v16a1.5 1.5 0 0 0 3 0V8h-3"/><path d="M4 4v16a1.5 1.5 0 0 0 1.5 1.5H18.5"/><path d="M7 8h7M7 12h7M7 16h4"/>',
    heart:  '<path d="M12 20s-7.5-4.5-7.5-10A4.3 4.3 0 0 1 12 7.5 4.3 4.3 0 0 1 19.5 10c0 5.5-7.5 10-7.5 10z"/>',
    bulb:   '<path d="M9 18h6M10 21h4"/><path d="M12 3a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2.1h5c0-.9.4-1.6 1-2.1A6 6 0 0 0 12 3z"/>',
    bottle: '<path d="M10 2h4v4l2 3v12a1 1 0 0 1-1 1H9a1 1 0 0 1-1-1V9l2-3z"/><path d="M8 13h8"/>',
    soy:    '<path d="M9 2h6M10 2v4L6.5 10v10.5A1.5 1.5 0 0 0 8 22h8a1.5 1.5 0 0 0 1.5-1.5V10L14 6V2"/><path d="M6.5 14h11"/>',
    candy:  '<circle cx="12" cy="12" r="4.5"/><path d="M7.5 12L3 9v6zM16.5 12l4.5-3v6z"/><path d="M10 10.5l4 3"/>',
    frozen: '<path d="M12 2v20M3.3 7l17.4 10M3.3 17l17.4-10"/><path d="M9.5 3.5L12 6l2.5-2.5M9.5 20.5L12 18l2.5 2.5"/>',
    mail:   '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3.5 6l8.5 7 8.5-7"/>',
    yen:    '<path d="M6 3l6 8 6-8M12 11v10M7.5 13.5h9M7.5 17h9"/>',
    globe:  '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 2.6 3.8 5.6 3.8 9s-1.3 6.4-3.8 9c-2.5-2.6-3.8-5.6-3.8-9S9.5 5.6 12 3z"/>'
  };
  function icon(name, size, color, sw){
    return '<svg class="ico" viewBox="0 0 24 24" width="'+size+'" height="'+size+'" fill="none" stroke="'+(color||"currentColor")+'" stroke-width="'+(sw||1.8)+'" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">'+(P[name]||"")+'</svg>';
  }
  /* Hero illustration: a Japanese meal set with a price tag. */
  function heroArt(){
    return '<svg class="hero-art" viewBox="0 0 360 260" role="img" aria-label="Illustration of a Japanese meal: rice, miso soup, grilled fish and a price tag">'+
      '<ellipse cx="180" cy="232" rx="160" ry="18" fill="#efe9df"/>'+
      '<rect x="40" y="150" width="280" height="76" rx="14" fill="#c98a52"/><rect x="40" y="150" width="280" height="12" rx="6" fill="#b5763f"/>'+
      // rice bowl
      '<path d="M66 128h84c0 26-19 44-42 44s-42-18-42-44z" fill="#2a78d6"/><path d="M70 136h76" stroke="#ffffff" stroke-opacity=".5" stroke-width="4"/>'+
      '<path d="M70 128c2-22 18-32 38-32s36 10 38 32z" fill="#ffffff"/><circle cx="96" cy="112" r="2.5" fill="#e9e2d6"/><circle cx="114" cy="106" r="2.5" fill="#e9e2d6"/><circle cx="124" cy="118" r="2.5" fill="#e9e2d6"/>'+
      // miso soup
      '<path d="M174 132h74c0 22-16 38-37 38s-37-16-37-38z" fill="#d03b3b"/><ellipse cx="211" cy="132" rx="37" ry="9" fill="#c4874a"/><rect x="199" y="128" width="8" height="5" rx="1" fill="#f6f1e6"/><rect x="214" y="130" width="7" height="4" rx="1" fill="#f6f1e6"/><path d="M226 127l6 4" stroke="#1baf7a" stroke-width="3" stroke-linecap="round"/>'+
      '<path d="M200 118c-6-8 6-12 0-22M214 116c-6-8 6-12 0-22M228 118c-6-8 6-12 0-22" fill="none" stroke="#b9b2a7" stroke-width="3" stroke-linecap="round"/>'+
      // fish plate
      '<ellipse cx="282" cy="176" rx="40" ry="11" fill="#ffffff" stroke="#e1e0d9" stroke-width="2"/><path d="M252 170c10-14 36-14 46 0-10 12-36 12-46 0z" fill="#eda100"/><path d="M298 170l12-8v16z" fill="#eda100"/><circle cx="262" cy="167" r="2.4" fill="#0b0b0b"/><path d="M272 164c3 4 3 8 0 12M282 164c3 4 3 8 0 12" stroke="#c98400" stroke-width="2" fill="none"/>'+
      // chopsticks
      '<path d="M60 196l150-18M62 204l150-14" stroke="#8a5cd1" stroke-width="5" stroke-linecap="round"/>'+
      // price tag
      '<g transform="rotate(12 300 60)"><path d="M262 34h64l14 26-14 26h-64z" fill="#fff7ea" stroke="#d03b3b" stroke-width="3"/><circle cx="326" cy="60" r="5" fill="#ffffff" stroke="#d03b3b" stroke-width="3"/><text x="290" y="70" text-anchor="middle" font-family="Segoe UI,Arial,sans-serif" font-size="30" font-weight="800" fill="#d03b3b">¥</text></g>'+
      '<path d="M262 20l14-14 14 14M276 6v30" fill="none" stroke="#d03b3b" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" transform="translate(-40 6)"/>'+
      '</svg>';
  }
  /* Regional dishes illustration: hot pot, noodles, rice ball and dango around a map pin. */
  function dishArt(){
    return '<svg class="hero-art" viewBox="0 0 360 260" role="img" aria-label="Illustration of Japanese regional dishes: a hot pot, a noodle bowl, a rice ball and sweet dumplings">'+
      '<ellipse cx="180" cy="236" rx="165" ry="16" fill="#efe9df"/>'+
      // hot pot (center)
      '<path d="M96 150h168v10c0 34-30 58-66 58h-36c-36 0-66-24-66-58z" fill="#3b3430"/>'+
      '<rect x="80" y="142" width="200" height="14" rx="7" fill="#4a423c"/>'+
      '<ellipse cx="180" cy="146" rx="88" ry="16" fill="#c4874a"/>'+
      '<path d="M120 142c10-10 26-10 36 0M158 138c10-10 26-10 36 0M196 142c10-10 26-10 36 0" fill="#d9707a"/>'+
      '<path d="M120 142c10-10 26-10 36 0M158 138c10-10 26-10 36 0M196 142c10-10 26-10 36 0" fill="none" stroke="#f6f1e6" stroke-width="2"/>'+
      '<path d="M236 146l14-10" stroke="#1baf7a" stroke-width="5" stroke-linecap="round"/><circle cx="148" cy="150" r="7" fill="#8a6a4a"/>'+
      '<path d="M150 118c-8-10 8-14 0-28M180 112c-8-10 8-14 0-28M210 118c-8-10 8-14 0-28" fill="none" stroke="#b9b2a7" stroke-width="3.5" stroke-linecap="round"/>'+
      // noodle bowl (left)
      '<path d="M18 196h70c0 20-15 32-35 32s-35-12-35-32z" fill="#eda100"/><path d="M26 196c4-6 8 6 12 0s8 6 12 0 8 6 12 0 8 6 12 0" fill="none" stroke="#fff7ea" stroke-width="3"/>'+
      '<path d="M62 160l-10 36M74 162l-14 34" stroke="#8a5cd1" stroke-width="4" stroke-linecap="round"/>'+
      // rice ball (right)
      '<path d="M300 170c-8 0-30 38-30 50a10 10 0 0 0 10 10h40a10 10 0 0 0 10-10c0-12-22-50-30-50z" fill="#ffffff" stroke="#e1e0d9" stroke-width="2"/><rect x="286" y="206" width="28" height="24" fill="#2f3a2f"/>'+
      // dango (top right)
      '<path d="M296 40l-36 66" stroke="#b5763f" stroke-width="4" stroke-linecap="round"/><circle cx="291" cy="50" r="11" fill="#f2a7b8"/><circle cx="281" cy="69" r="11" fill="#ffffff" stroke="#e1e0d9" stroke-width="2"/><circle cx="271" cy="88" r="11" fill="#9bd18f"/>'+
      // map pin (top left)
      '<path d="M62 30a22 22 0 0 1 22 22c0 18-22 40-22 40s-22-22-22-40a22 22 0 0 1 22-22z" fill="#d03b3b"/><circle cx="62" cy="52" r="8" fill="#ffffff"/>'+
      '</svg>';
  }
  /* Market illustration: rising bars topped with food category items. */
  function marketArt(){
    return '<svg class="hero-art" viewBox="0 0 360 260" role="img" aria-label="Illustration of a bar chart with frozen food, a soy sauce bottle, candy and a soft drink bottle">'+
      '<ellipse cx="180" cy="238" rx="165" ry="14" fill="#efe9df"/>'+
      '<path d="M30 226h300" stroke="#c3c2b7" stroke-width="3" stroke-linecap="round"/>'+
      '<rect x="44" y="160" width="56" height="66" rx="6" fill="#2a78d6"/><rect x="116" y="138" width="56" height="88" rx="6" fill="#eb6834"/><rect x="188" y="150" width="56" height="76" rx="6" fill="#1baf7a"/><rect x="260" y="110" width="56" height="116" rx="6" fill="#eda100"/>'+
      // frozen box on bar 1
      '<rect x="50" y="118" width="44" height="38" rx="4" fill="#e8f1fc" stroke="#2a78d6" stroke-width="3"/><path d="M72 124v26M61 131l22 12M61 143l22-12" stroke="#2a78d6" stroke-width="2.5" stroke-linecap="round"/>'+
      // soy bottle on bar 2
      '<path d="M138 72h12v12l10 14v34a3 3 0 0 1-3 3h-26a3 3 0 0 1-3-3V98l10-14z" fill="#3b2a24"/><rect x="134" y="62" width="20" height="10" rx="2" fill="#d03b3b"/><rect x="132" y="104" width="24" height="16" rx="2" fill="#fff7ea"/>'+
      // candy on bar 3
      '<circle cx="216" cy="128" r="15" fill="#f2a7b8"/><path d="M201 128l-14-9v18zM231 128l14-9v18z" fill="#f2a7b8"/><path d="M208 120l14 14" stroke="#ffffff" stroke-width="3"/>'+
      // drink bottle on bar 4
      '<path d="M281 40h14v12l8 12v40a4 4 0 0 1-4 4h-22a4 4 0 0 1-4-4V64l8-12z" fill="#bfe3f7" stroke="#2a78d6" stroke-width="3"/><rect x="279" y="32" width="18" height="8" rx="2" fill="#1baf7a"/><rect x="273" y="74" width="30" height="14" fill="#eda100"/>'+
      '<path d="M40 96l60-30 56 18 60-40 60 8" fill="none" stroke="#d03b3b" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="2 9"/>'+
      '</svg>';
  }
  window.JL = { icon: icon, heroArt: heroArt, dishArt: dishArt, marketArt: marketArt, has: function(n){ return !!P[n]; } };
})();
