import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { aiAutomationService } from '../../services/aiAutomationService';
import type { UseAISuggestionsReturn } from './types';

export const useAISuggestions = (): UseAISuggestionsReturn => {
  const queryClient = useQueryClient();

  const {
    data: suggestions = [],
    isLoading,
    error,
    refetch,
  } = useQuery({
    queryKey: ['ai-suggestions'],
    queryFn: () => aiAutomationService.getSuggestions(),
    staleTime: 2 * 60 * 1000,
  });

  const acceptMutation = useMutation({
    mutationFn: (suggestionId: string) => aiAutomationService.acceptSuggestion(suggestionId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ai-suggestions'] });
    },
  });

  const rejectMutation = useMutation({
    mutationFn: (suggestionId: string) => aiAutomationService.rejectSuggestion(suggestionId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ai-suggestions'] });
    },
  });

  const feedbackMutation = useMutation({
    mutationFn: ({
      suggestionId,
      wasHelpful,
      correctionPayload,
    }: {
      suggestionId: string;
      wasHelpful: boolean;
      correctionPayload?: Record<string, unknown>;
    }) => aiAutomationService.submitFeedback(suggestionId, wasHelpful, correctionPayload),
  });

  return {
    suggestions,
    isLoading,
    error,
    refetch,
    acceptSuggestion: acceptMutation.mutateAsync,
    rejectSuggestion: rejectMutation.mutateAsync,
    submitFeedback: feedbackMutation.mutateAsync,
    isAccepting: acceptMutation.isPending,
    isRejecting: rejectMutation.isPending,
  };
};
