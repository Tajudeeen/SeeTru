import 'package:flutter/material.dart';
import 'package:get/get.dart';

class XPost {
  final String id;
  final String authorName;
  final String authorHandle;
  final String authorAvatar;
  final bool isVerified;
  final bool isKOL;
  final String content;
  final List<String> hashtags;
  final List<String> mentionedTokens;
  final int likes;
  final int retweets;
  final int replies;
  final DateTime postedAt;
  final String? imageUrl;
  final String sentiment; // 'bullish', 'bearish', 'neutral'

  const XPost({
    required this.id,
    required this.authorName,
    required this.authorHandle,
    required this.authorAvatar,
    required this.isVerified,
    required this.isKOL,
    required this.content,
    required this.hashtags,
    required this.mentionedTokens,
    required this.likes,
    required this.retweets,
    required this.replies,
    required this.postedAt,
    this.imageUrl,
    required this.sentiment,
  });
}

class TrendingTopic {
  final String tag;
  final String tweetCount;
  final String change;
  final bool isPositive;
  final String category;

  const TrendingTopic({
    required this.tag,
    required this.tweetCount,
    required this.change,
    required this.isPositive,
    required this.category,
  });
}

class KOLAccount {
  final String name;
  final String handle;
  final String avatar;
  final String followers;
  final String category;
  final bool isFollowing;

  const KOLAccount({
    required this.name,
    required this.handle,
    required this.avatar,
    required this.followers,
    required this.category,
    required this.isFollowing,
  });
}

class SocialController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxString activeTab = 'Feed'.obs;
  final RxString activeFeedFilter = 'All'.obs;
  final RxBool isSearchActive = false.obs;
  final RxString searchQuery = ''.obs;

  // ── Data ───────────────────────────────────────────────────────────
  final RxList<XPost> feedPosts = <XPost>[].obs;
  final RxList<XPost> filteredPosts = <XPost>[].obs;
  final RxList<TrendingTopic> trendingTopics = <TrendingTopic>[].obs;
  final RxList<KOLAccount> kols = <KOLAccount>[].obs;
  final RxMap<String, String> sentimentData = <String, String>{}.obs;

  final List<String> tabs = ['Feed', 'Trending', 'KOLs', 'Sentiment'].obs;
  final List<String> feedFilters = ['All', 'Bullish', 'Bearish', 'Alpha'].obs;

  final searchController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    _populateMockData();
    isLoading.value = false;
  }

  @override
  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _populateMockData();
  }

  void _populateMockData() {
    feedPosts.value = [
      XPost(
        id: '1',
        authorName: 'Deeen Code',
        authorHandle: '@Deeen_Code',
        authorAvatar: '🦁',
        isVerified: true,
        isKOL: true,
        content:
            '\$BTC breaking above the 4-hour resistance at \$67,400. Next target is \$72K. We\'ve been saying this level was critical. The liquidity zone above is clean. 🚀\n\n#Bitcoin #BTC #Crypto',
        hashtags: ['#Bitcoin', '#BTC', '#Crypto'],
        mentionedTokens: ['BTC'],
        likes: 4821,
        retweets: 1203,
        replies: 287,
        postedAt: DateTime.now().subtract(const Duration(minutes: 14)),
        sentiment: 'bullish',
      ),
      XPost(
        id: '2',
        authorName: 'Zarv',
        authorHandle: '@zarvxbt',
        authorAvatar: '💜',
        isVerified: true,
        isKOL: false,
        content:
            'Dencun upgrade has now processed over 10M blobs. Layer 2 transaction costs are down 99% on average since the upgrade went live. The scalability roadmap is on track. \$ETH',
        hashtags: ['#Ethereum', '#Dencun'],
        mentionedTokens: ['ETH'],
        likes: 12400,
        retweets: 3800,
        replies: 742,
        postedAt: DateTime.now().subtract(const Duration(hours: 1)),
        sentiment: 'bullish',
      ),
      XPost(
        id: '3',
        authorName: 'Khadee',
        authorHandle: '@dee_nftarmy',
        authorAvatar: '❤️',
        isVerified: true,
        isKOL: true,
        content:
            'Everything people said was dead is pumping again. This is crypto. Never fight the market structure. \$SOL \$SUI \$APT all looking clean on the weekly.',
        hashtags: ['#Solana', '#Sui', '#Aptos'],
        mentionedTokens: ['SOL', 'SUI', 'APT'],
        likes: 7240,
        retweets: 2100,
        replies: 512,
        postedAt: DateTime.now().subtract(const Duration(hours: 2)),
        sentiment: 'bullish',
      ),
      XPost(
        id: '4',
        authorName: 'Anointed',
        authorHandle: '@kryptonoob',
        authorAvatar: '🏔️',
        isVerified: true,
        isKOL: true,
        content:
            'The Fed is trapped. They cannot raise, they dare not cut meaningfully. Fiat debasement continues. Hard assets — BTC, gold, real estate — outperform in this regime. Position accordingly.',
        hashtags: ['#Fed', '#Bitcoin', '#Macro'],
        mentionedTokens: ['BTC'],
        likes: 9180,
        retweets: 2940,
        replies: 831,
        postedAt: DateTime.now().subtract(const Duration(hours: 4)),
        sentiment: 'bullish',
      ),
      XPost(
        id: '5',
        authorName: 'sammy',
        authorHandle: '@that_nft_boy',
        authorAvatar: '🔮',
        isVerified: true,
        isKOL: true,
        content:
            'Careful here — the funding rates on \$BTC perps are running extremely elevated. When everyone is leaning one way in leverage, the move tends to disappoint. Could see a flush before continuation.',
        hashtags: ['#Bitcoin', '#Trading'],
        mentionedTokens: ['BTC'],
        likes: 3410,
        retweets: 920,
        replies: 340,
        postedAt: DateTime.now().subtract(const Duration(hours: 5)),
        sentiment: 'bearish',
      ),
    ];

    filteredPosts.value = feedPosts;

    trendingTopics.value = [
      const TrendingTopic(
        tag: '#Bitcoin',
        tweetCount: '142.4K',
        change: '+22%',
        isPositive: true,
        category: 'Crypto',
      ),
      const TrendingTopic(
        tag: '#ETHDencun',
        tweetCount: '84.2K',
        change: '+58%',
        isPositive: true,
        category: 'Ethereum',
      ),
      const TrendingTopic(
        tag: '#SUI',
        tweetCount: '61.8K',
        change: '+93%',
        isPositive: true,
        category: 'DeFi',
      ),
      const TrendingTopic(
        tag: '#FedPolicy',
        tweetCount: '45.1K',
        change: '-4%',
        isPositive: false,
        category: 'Macro',
      ),
      const TrendingTopic(
        tag: '#Solana',
        tweetCount: '38.5K',
        change: '+12%',
        isPositive: true,
        category: 'L1',
      ),
      const TrendingTopic(
        tag: '#NFTs',
        tweetCount: '22.0K',
        change: '-8%',
        isPositive: false,
        category: 'NFT',
      ),
    ];

    kols.value = [
      KOLAccount(
        name: 'Crypto Kaleo',
        handle: '@CryptoKaleo',
        avatar: '🦁',
        followers: '742K',
        category: 'Technical Analysis',
        isFollowing: true,
      ),
      KOLAccount(
        name: 'Arthur Hayes',
        handle: '@CryptoHayes',
        avatar: '🏔️',
        followers: '1.2M',
        category: 'Macro / Bitcoin',
        isFollowing: false,
      ),
      KOLAccount(
        name: 'Ansem',
        handle: '@blknoiz06',
        avatar: '🐸',
        followers: '480K',
        category: 'Altcoins / Degen',
        isFollowing: true,
      ),
      KOLAccount(
        name: 'Hsaka',
        handle: '@HsakaTrades',
        avatar: '🔮',
        followers: '320K',
        category: 'Trading / TA',
        isFollowing: false,
      ),
      KOLAccount(
        name: 'Wintermute',
        handle: '@wintermute_t',
        avatar: '🌊',
        followers: '85K',
        category: 'Market Making / DeFi',
        isFollowing: false,
      ),
    ];

    sentimentData.value = {
      'BTC': 'Bullish',
      'ETH': 'Bullish',
      'SOL': 'Neutral',
      'SUI': 'Very Bullish',
      'Overall': 'Greed',
    };
  }

  void setActiveTab(String tab) => activeTab.value = tab;

  void setFeedFilter(String filter) {
    activeFeedFilter.value = filter;
    if (filter == 'All') {
      filteredPosts.value = feedPosts;
    } else {
      final f = filter.toLowerCase();
      filteredPosts.value = feedPosts
          .where((p) => p.sentiment == f || (f == 'alpha' && p.isKOL))
          .toList();
    }
  }

  void toggleSearch() => isSearchActive.value = !isSearchActive.value;

  void onSearchChanged(String q) {
    searchQuery.value = q;
    if (q.isEmpty) {
      filteredPosts.value = feedPosts;
    } else {
      filteredPosts.value = feedPosts
          .where(
            (p) =>
                p.content.toLowerCase().contains(q.toLowerCase()) ||
                p.authorHandle.toLowerCase().contains(q.toLowerCase()) ||
                p.mentionedTokens.any(
                  (t) => t.toLowerCase().contains(q.toLowerCase()),
                ),
          )
          .toList();
    }
  }

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
