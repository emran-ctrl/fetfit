import { createApp } from '@backstage/frontend-defaults';
import catalogPlugin from '@backstage/plugin-catalog/alpha';
import {
  configApiRef,
  githubAuthApiRef,
  useApi,
} from '@backstage/core-plugin-api';
import { SignInPage } from '@backstage/core-components';
import { SignInPageBlueprint } from '@backstage/plugin-app-react';
import { createFrontendModule } from '@backstage/frontend-plugin-api';
import { catalogFiltersModule } from './modules/catalog-filters';
import { navModule } from './modules/nav';
import { homeModule } from './modules/home';

const githubProvider = {
  id: 'github-auth-provider',
  title: 'GitHub',
  message: 'Sign in using GitHub',
  apiRef: githubAuthApiRef,
};

const signInPage = SignInPageBlueprint.make({
  params: {
    loader: async () => props => {
      const configApi = useApi(configApiRef);
      const environment =
        configApi.getOptionalString('auth.environment') ?? 'development';
      const isDevelopment = environment === 'development';

      return (
        <SignInPage
          {...props}
          providers={
            isDevelopment ? ['guest', githubProvider] : [githubProvider]
          }
        />
      );
    },
  },
});

export default createApp({
  features: [
    catalogPlugin,
    catalogFiltersModule,
    navModule,
    homeModule,
    createFrontendModule({
      pluginId: 'app',
      extensions: [signInPage],
    }),
  ],
});
