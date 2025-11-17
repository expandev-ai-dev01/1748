import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { aiAutomationService } from '../../services/aiAutomationService';
import type { UseAutomationRulesReturn, UseAutomationRulesOptions } from './types';
import type { CreateAutomationRuleDto, UpdateAutomationRuleDto } from '../../types';

export const useAutomationRules = (
  options: UseAutomationRulesOptions = {}
): UseAutomationRulesReturn => {
  const queryClient = useQueryClient();

  const {
    data: rules = [],
    isLoading,
    error,
    refetch,
  } = useQuery({
    queryKey: ['automation-rules'],
    queryFn: () => aiAutomationService.listAutomationRules(),
    staleTime: 5 * 60 * 1000,
  });

  const createMutation = useMutation({
    mutationFn: (data: CreateAutomationRuleDto) => aiAutomationService.createAutomationRule(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['automation-rules'] });
      options.onSuccess?.();
    },
    onError: (error: Error) => {
      options.onError?.(error);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ ruleId, data }: { ruleId: string; data: UpdateAutomationRuleDto }) =>
      aiAutomationService.updateAutomationRule(ruleId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['automation-rules'] });
      options.onSuccess?.();
    },
    onError: (error: Error) => {
      options.onError?.(error);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (ruleId: string) => aiAutomationService.deleteAutomationRule(ruleId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['automation-rules'] });
    },
  });

  const toggleMutation = useMutation({
    mutationFn: ({ ruleId, isActive }: { ruleId: string; isActive: boolean }) =>
      aiAutomationService.toggleAutomationRule(ruleId, isActive),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['automation-rules'] });
    },
  });

  return {
    rules,
    isLoading,
    error,
    refetch,
    createRule: createMutation.mutateAsync,
    updateRule: updateMutation.mutateAsync,
    deleteRule: deleteMutation.mutateAsync,
    toggleRule: toggleMutation.mutateAsync,
    isCreating: createMutation.isPending,
    isUpdating: updateMutation.isPending,
    isDeleting: deleteMutation.isPending,
    isToggling: toggleMutation.isPending,
  };
};
