import { NativeEventEmitter, NativeModules } from 'react-native';

const { LocalSearchManager } = NativeModules;

const LocalSearchEventEmitter = new NativeEventEmitter(LocalSearchManager);

export type SearchLocationResultItem = {
  title: string;
  subtitle: string;
};

export type LocationResult = {
  name: string;
  latitude: number;
  longitude: number;
};

export const searchLocationsAutocomplete = async (text: string) => {
  await LocalSearchManager.searchLocationsAutocomplete(text);
};

export const updatedLocationResultsListener = (
  listener: (event: SearchLocationResultItem[]) => Promise<void> | void
) => {
  const emitterSubscription = LocalSearchEventEmitter.addListener(
    'onUpdatedLocationResults',
    listener
  );

  return emitterSubscription;
};

export const searchPointsOfInterest = async (near: {
  latitude: number;
  longitude: number;
  latitudeDelta: number;
  longitudeDelta: number;
}): Promise<LocationResult[]> => {
  const result = await LocalSearchManager.searchPointsOfInterest(near);
  return result;
};

export const searchLocations = async (
  query: string,
  near: {
    latitude: number;
    longitude: number;
    latitudeDelta: number;
    longitudeDelta: number;
  }
): Promise<LocationResult[]> => {
  const result = await LocalSearchManager.searchLocations(query, near);
  return result;
};
