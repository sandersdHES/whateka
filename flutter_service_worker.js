'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "8390ffc17768786be0422f93be5d5ad8",
"version.json": "0a46d2eac28e298f7401f1488cd8f93a",
"index.html": "33015f660b4fc41127f3399b4a840b6e",
"/": "33015f660b4fc41127f3399b4a840b6e",
"main.dart.js": "060bbd6ebe89b805ffc204cad4f719b6",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "f5690016e78842b7ca256e118864970f",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "72cea6a6af67cc37b3f36178972225a1",
".git/config": "38881ccff4dc4e249623736f3cd97a15",
".git/objects/61/0978ea80c03b8ee8ef14ee52f10c0cfa271e23": "dc852edd297516ca6fce2796f5ec7321",
".git/objects/68/43fddc6aef172d5576ecce56160b1c73bc0f85": "2a91c358adf65703ab820ee54e7aff37",
".git/objects/6f/7661bc79baa113f478e9a717e0c4959a3f3d27": "985be3a6935e9d31febd5205a9e04c4e",
".git/objects/69/b2023ef3b84225f16fdd15ba36b2b5fc3cee43": "6ccef18e05a49674444167a08de6e407",
".git/objects/3c/ee124377d2fce837f10723e7ea5eb309f5ab11": "7ffb211ca76b3109a414028bf2e66849",
".git/objects/51/03e757c71f2abfd2269054a790f775ec61ffa4": "d437b77e41df8fcc0c0e99f143adc093",
".git/objects/0b/9fcf3d6c6058acc662279d9d22099086a0c78a": "0f20d8b31472ed851f3506e98bb44282",
".git/objects/93/b363f37b4951e6c5b9e1932ed169c9928b1e90": "c8d74fb3083c0dc39be8cff78a1d4dd5",
".git/objects/33/9f5bf99b7097dd7ac61db041fa35fe929add31": "eea16328b62918605661302a68d72434",
".git/objects/9c/16261420e147f7de4537761928dd02057bca53": "710be1e6b79f7dd7a02e3ba51f95768b",
".git/objects/d9/5b1d3499b3b3d3989fa2a461151ba2abd92a07": "a072a09ac2efe43c8d49b7356317e52e",
".git/objects/ad/ced61befd6b9d30829511317b07b72e66918a1": "37e7fcca73f0b6930673b256fac467ae",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/e2/1925b023fb7ade2bab69dea78d9c08646809b1": "41fd496de474320b3246dc27745e3b96",
".git/objects/f4/42e920f8bf188872e775a286c2fc24d57bbb40": "5517d2f27c709bcdf7df0f5e6715c1bd",
".git/objects/f3/3e0726c3581f96c51f862cf61120af36599a32": "afcaefd94c5f13d3da610e0defa27e50",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/c7/d9d66dba4434e881693624b7a4a7443b9c1df8": "a22d6b99afe85337cdcce75b26355fb3",
".git/objects/fd/05cfbc927a4fedcbe4d6d4b62e2c1ed8918f26": "5675c69555d005a1a244cc8ba90a402c",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/e4/2a0334ecf518aa3890da633cbdc7bc5212ec1d": "33b7429ab75a92fb3781279a3c3b0fd5",
".git/objects/fe/d0e7884e784b0eee96d46989a8e83bc56afc62": "7c74d6046f785d9497e237e9776cc703",
".git/objects/c8/f858581876dfbc08d9be2c5d75c636faf469a1": "4512e21f3633a251d90d52c9ea68bbc2",
".git/objects/c8/7e051a9d6085baf011ac6eeadd6f60d20ca462": "9c3f93819b95e91d656b60305bf091be",
".git/objects/c8/3af99da428c63c1f82efdcd11c8d5297bddb04": "144ef6d9a8ff9a753d6e3b9573d5242f",
".git/objects/fb/0ac0819861d8c743c0a486831441c3b1e9eb72": "cf16aabcc76a45beeef980ffb51f9f6f",
".git/objects/fb/2127fe0065fbf0c1fc8231baf9fafc0836eaf5": "687ae14361956c70dcbf195a9437462c",
".git/objects/4b/867e2d7a342be73bbf0d6b22d102d14e832531": "02158c5c7f9632fa0171726c1fc5ce56",
".git/objects/4b/283b3c70f5c0913ddc50867cc205885aa3310c": "8cb0c8ec02050a3faaf2178c0bb59be5",
".git/objects/7c/3463b788d022128d17b29072564326f1fd8819": "37fee507a59e935fc85169a822943ba2",
".git/objects/42/2bc5e2331db0946f94ef7f217c899a33322171": "63355ecb83eda4503d315c6f17eb4716",
".git/objects/87/e863bf2c6aa68041daa014102cf733b23f4f93": "1f79e6e04851d5382da2006f7022ddab",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/4c/1c9bc0def6dfeffce4d8adaaa44286796d2dad": "30609ab711c750070a33536aad445f77",
".git/objects/21/1a0e142764f33d7e19331b225626d8686a3af4": "47b698ffccbd89b33b8b5c7613122f5d",
".git/objects/86/03d0a3d2a91580f77171968c7d13e73fd1482a": "dc750bd17c929d834d260dd7dc0293e7",
".git/objects/2a/6232105fabfd82b3c90717ccc2d55f8fd826b8": "54fdde0e358b01ef2aaca58d63f37a1b",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/07/42796b73f3f5ea8a8ac7f965154f522532a312": "d0e2bf0b4c9af3c5be6cf6b228a41283",
".git/objects/36/cdfb83f2a3d497182bcedbae35ab4cc313a656": "a292ba75fc05d4b8d7690f0a7af75f33",
".git/objects/3a/8cda5335b4b2a108123194b84df133bac91b23": "1636ee51263ed072c69e4e3b8d14f339",
".git/objects/98/cbdf4d72e951564f06a986d13539b0e4a52cb0": "e19b2901b18672c786541ced574bc4c0",
".git/objects/5e/c2c2de8462692092892db1e1cd6137b036dae8": "fec9c233c104cf0dd81a87629307569b",
".git/objects/08/27c17254fd3959af211aaf91a82d3b9a804c2f": "360dc8df65dabbf4e7f858711c46cc09",
".git/objects/6d/711a01ee7f2b795775f011140bbec54ff7235d": "f2c755f29e0df61227ba39c9e04b5c6f",
".git/objects/01/402637a19d729ba55f7aec738123bdc868fa6d": "4b40349dcde3b7a0368cba300316708b",
".git/objects/39/4f8c9d47e0ae94bac8485bfb2e8cd5f9cd77cd": "52b703b40751320d9cf530b942d4e8c4",
".git/objects/55/de609f336246ef16984a9de3b4d6de09975062": "ca5344822d853cf92a977c985d9cc951",
".git/objects/63/20bafa3bc9e50ec0c3cca03719fd2c3ce0d32b": "15d0c4af6d370696721cc2efbec72e01",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/a7/89c506d1af384cb7cc72402592c1004cc6781e": "3494efb1dfab6b0c26b77686804efed4",
".git/objects/b1/3c16b38cba18e485f114b3aa519481efe7e5b1": "e1ffbb3b94a8791c5bc290ae60f35776",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/db/842e6eb5eb7b8f6700222b1b10aefe2f328b35": "2512baffa560e65b1235d197937eb978",
".git/objects/a8/9b4098c0e9eea9f2dc405de07a8e7bb6ce5d7a": "c10fb8696395e85a05ea3f5a80162adc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/3e39bd49dfaf9e225bb598cd9644f833badd9a": "666b0d595ebbcc37f0c7b61220c18864",
".git/objects/c4/7d8bcad40ee126b1fac2addb476bab81ac497e": "41d15370827940dcf4947ccab9a64b85",
".git/objects/ea/5ecd5baf7715092cd884d4bb203e85af189d0a": "11fc8cd7420cfc90831111c73f53802f",
".git/objects/e6/eb8f689cbc9febb5a913856382d297dae0d383": "466fce65fb82283da16cdd7c93059ff3",
".git/objects/c2/1713b63529b11b1c88ed0a2380ef037b9bd354": "1064909d33c44f89ead41e2d5abf8161",
".git/objects/f6/e6c75d6f1151eeb165a90f04b4d99effa41e83": "95ea83d65d44e4c524c6d51286406ac8",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/e0/7797437d096064bd90c373800dcb0f335c14b0": "16f9b9defb16491f8c733b09b022688c",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/2c/e78d28f987f9cca82ec7e1468636fbfd7d7f67": "7242ce78bf28ecb7102f3a797f08f05b",
".git/objects/23/d65c87d9cf4a712a91059a43537f4ac3700c70": "22fe7c3966d881ef47331a14049bf2c1",
".git/objects/8d/1a22f07d472bf45bc9c21b45c20e501f5fdab3": "cb5d28345cd23708f5e071cb339d739c",
".git/objects/12/1b0fa337d2e8fdc45967bd4da8f8182320f03f": "808f5558f878b76290ed6e270745188c",
".git/objects/85/63aed2175379d2e75ec05ec0373a302730b6ad": "997f96db42b2dde7c208b10d023a5a8e",
".git/objects/49/b465ab12a992e6cf491fbc5f5bcc0269aebb40": "4685894bf272aba9373d05a90e410a36",
".git/objects/49/329da2f534ea89d6f645ca022245adb1335112": "3d62e770fef52f2a6154aa5d1809c9d8",
".git/objects/2e/0bc2997b763b2c81ded840a65fcdb994719f45": "7a4016f657a832518624726c2487cb22",
".git/objects/2b/9cf0dd620d0275fc471c93d2d3bf5fc45f71ca": "5eb3fe60183aaee04f09db78275b1e08",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "86c4c19d5e65c3bd08ab42b482e08768",
".git/logs/refs/heads/main": "86c4c19d5e65c3bd08ab42b482e08768",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/refs/heads/main": "6a16c535863cc0b7909acb57928501e9",
".git/index": "75598c5afabaac3b3ac1abd79561051c",
".git/COMMIT_EDITMSG": "8439beb8b1732c0a2985d22d90c57484",
"assets/NOTICES": "35e23c3707eaeb3af4d774ec5e322d47",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "2bdcc2e0d7857946c22b4ad3867b3049",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "7eefd17f5d24aee5cdfbafa846037e54",
"assets/fonts/MaterialIcons-Regular.otf": "e169514bc1e9fb652f3f1a1f7dfde9d8",
"assets/assets/images/home_icon_square.png": "7c49e9b947759f76237609f215dce0ae",
"assets/assets/images/home_icon.png": "f5690016e78842b7ca256e118864970f",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
