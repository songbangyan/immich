<script lang="ts">
  import Icon from '$lib/components/elements/icon.svelte';
  import { locale } from '$lib/stores/preferences.store';
  import { getByteUnitString, getBytesWithUnit } from '$lib/utils/byte-units';
  import type { ServerStatsResponseDto } from '@immich/sdk';
  import { mdiCameraIris, mdiChartPie, mdiPlayCircle } from '@mdi/js';
  import { t } from 'svelte-i18n';
  import StatsCard from './stats-card.svelte';

  interface Props {
    stats?: ServerStatsResponseDto;
  }

  let {
    stats = {
      photos: 0,
      videos: 0,
      usage: 0,
      usagePhotos: 0,
      usageVideos: 0,
      usageByUser: [],
    },
  }: Props = $props();

  const zeros = (value: number) => {
    const maxLength = 13;
    const valueLength = value.toString().length;
    const zeroLength = maxLength - valueLength;

    return '0'.repeat(zeroLength);
  };

  const TiB = 1024 ** 4;
  let [statsUsage, statsUsageUnit] = $derived(getBytesWithUnit(stats.usage, stats.usage > TiB ? 2 : 0));
</script>

<div class="flex flex-col gap-5">
  <div>
    <p class="text-sm dark:text-immich-dark-fg">{$t('total_usage').toUpperCase()}</p>

    <div class="mt-5 hidden justify-between lg:flex gap-4">
      <StatsCard icon={mdiCameraIris} title={$t('photos').toUpperCase()} value={stats.photos} />
      <StatsCard icon={mdiPlayCircle} title={$t('videos').toUpperCase()} value={stats.videos} />
      <StatsCard icon={mdiChartPie} title={$t('storage').toUpperCase()} value={statsUsage} unit={statsUsageUnit} />
    </div>
    <div class="mt-5 flex lg:hidden">
      <div class="flex flex-col justify-between rounded-3xl bg-subtle p-5 dark:bg-immich-dark-gray">
        <div class="flex flex-wrap gap-x-12">
          <div class="flex place-items-center gap-4 text-immich-primary dark:text-immich-dark-primary">
            <Icon path={mdiCameraIris} size="25" />
            <p>{$t('photos').toUpperCase()}</p>
          </div>

          <div class="relative text-center font-mono text-2xl font-semibold">
            <span class="text-[#DCDADA] dark:text-[#525252]">{zeros(stats.photos)}</span><span
              class="text-immich-primary dark:text-immich-dark-primary">{stats.photos}</span
            >
          </div>
        </div>
        <div class="flex flex-wrap gap-x-12">
          <div class="flex place-items-center gap-4 text-immich-primary dark:text-immich-dark-primary">
            <Icon path={mdiPlayCircle} size="25" />
            <p>{$t('videos').toUpperCase()}</p>
          </div>

          <div class="relative text-center font-mono text-2xl font-semibold">
            <span class="text-[#DCDADA] dark:text-[#525252]">{zeros(stats.videos)}</span><span
              class="text-immich-primary dark:text-immich-dark-primary">{stats.videos}</span
            >
          </div>
        </div>
        <div class="flex flex-wrap gap-x-7">
          <div class="flex place-items-center gap-4 text-immich-primary dark:text-immich-dark-primary">
            <Icon path={mdiChartPie} size="25" />
            <p>{$t('storage').toUpperCase()}</p>
          </div>

          <div class="relative flex text-center font-mono text-2xl font-semibold">
            <span class="text-[#DCDADA] dark:text-[#525252]">{zeros(statsUsage)}</span><span
              class="text-immich-primary dark:text-immich-dark-primary">{statsUsage}</span
            >
            <span class="my-auto ms-2 text-center text-base font-light text-gray-400">{statsUsageUnit}</span>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div>
    <p class="text-sm dark:text-immich-dark-fg">{$t('user_usage_detail').toUpperCase()}</p>
    <table class="mt-5 w-full text-start">
      <thead
        class="mb-4 flex h-12 w-full rounded-md border bg-gray-50 text-immich-primary dark:border-immich-dark-gray dark:bg-immich-dark-gray dark:text-immich-dark-primary"
      >
        <tr class="flex w-full place-items-center">
          <th class="w-1/4 text-center text-sm font-medium">{$t('user')}</th>
          <th class="w-1/4 text-center text-sm font-medium">{$t('photos')}</th>
          <th class="w-1/4 text-center text-sm font-medium">{$t('videos')}</th>
          <th class="w-1/4 text-center text-sm font-medium">{$t('usage')}</th>
        </tr>
      </thead>
      <tbody
        class="block max-h-[320px] w-full overflow-y-auto rounded-md border dark:border-immich-dark-gray dark:text-immich-dark-fg"
      >
        {#each stats.usageByUser as user (user.userId)}
          <tr class="flex h-[50px] w-full place-items-center text-center even:bg-subtle/20 odd:bg-subtle/80">
            <td class="w-1/4 text-ellipsis px-2 text-sm">{user.userName}</td>
            <td class="w-1/4 text-ellipsis px-2 text-sm"
              >{user.photos.toLocaleString($locale)} ({getByteUnitString(user.usagePhotos, $locale, 0)})</td
            >
            <td class="w-1/4 text-ellipsis px-2 text-sm"
              >{user.videos.toLocaleString($locale)} ({getByteUnitString(user.usageVideos, $locale, 0)})</td
            >
            <td class="w-1/4 text-ellipsis px-2 text-sm">
              {getByteUnitString(user.usage, $locale, 0)}
              {#if user.quotaSizeInBytes !== null}
                / {getByteUnitString(user.quotaSizeInBytes, $locale, 0)}
              {/if}
              <span class="text-immich-primary dark:text-immich-dark-primary">
                {#if user.quotaSizeInBytes !== null && user.quotaSizeInBytes >= 0}
                  ({(user.quotaSizeInBytes === 0 ? 1 : user.usage / user.quotaSizeInBytes).toLocaleString($locale, {
                    style: 'percent',
                    maximumFractionDigits: 0,
                  })})
                {:else}
                  ({$t('unlimited')})
                {/if}
              </span>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
</div>
