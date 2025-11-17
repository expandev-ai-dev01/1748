import type { AISuggestion } from '../../types';

export interface UseAISuggestionsReturn {
  suggestions: AISuggestion[];
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
  acceptSuggestion: (suggestionId: string) => Promise<void>;
  rejectSuggestion: (suggestionId: string) => Promise<void>;
  submitFeedback: (params: {
    suggestionId: string;
    wasHelpful: boolean;
    correctionPayload?: Record<string, unknown>;
  }) => Promise<unknown>;
  isAccepting: boolean;
  isRejecting: boolean;
}
