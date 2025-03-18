import 'package:poker_night/core/services/app_links_deep_link_service.dart';
import 'package:poker_night/core/services/deep_link_service_interface.dart';

/// Enum para representar os tipos de serviço de deep link disponíveis
enum DeepLinkServiceType {
  appLinks,
}

/// Factory para criar instâncias de serviços de deep link
class DeepLinkServiceFactory {
  /// Cria uma instância de um serviço de deep link
  static DeepLinkServiceInterface createDeepLinkService({
    DeepLinkServiceType type = DeepLinkServiceType.appLinks,
  }) {
    switch (type) {
      case DeepLinkServiceType.appLinks:
        return AppLinksDeepLinkService();
    }
  }
}
