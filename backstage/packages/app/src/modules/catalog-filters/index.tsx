import { createFrontendModule } from '@backstage/frontend-plugin-api';
import {
  DefaultEntityFilters,
  EntityAutocompletePicker,
  EntityFilter,
} from '@backstage/plugin-catalog-react';
import { CatalogFilterBlueprint } from '@backstage/plugin-catalog-react/alpha';

type CatalogFilters = DefaultEntityFilters & { systems?: SystemFilter };

class SystemFilter implements EntityFilter {
  constructor(readonly values: string[]) {}

  getCatalogFilters(): { 'spec.system': string[] } {
    return { 'spec.system': this.values };
  }
}

const catalogSystemFilter = CatalogFilterBlueprint.make({
  name: 'system',
  params: {
    loader: async () => (
      <EntityAutocompletePicker<CatalogFilters, 'systems'>
        label="System"
        name="systems"
        path="spec.system"
        Filter={SystemFilter}
        filtersForAvailableValues={['kind', 'lifecycles']}
      />
    ),
  },
});

export const catalogFiltersModule = createFrontendModule({
  pluginId: 'catalog',
  extensions: [catalogSystemFilter],
});