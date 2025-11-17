import type { AutomationRule, CreateAutomationRuleDto, UpdateAutomationRuleDto } from '../../types';

export interface UseAutomationRulesOptions {
  onSuccess?: () => void;
  onError?: (error: Error) => void;
}

export interface UseAutomationRulesReturn {
  rules: AutomationRule[];
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
  createRule: (data: CreateAutomationRuleDto) => Promise<AutomationRule>;
  updateRule: (params: {
    ruleId: string;
    data: UpdateAutomationRuleDto;
  }) => Promise<AutomationRule>;
  deleteRule: (ruleId: string) => Promise<void>;
  toggleRule: (params: { ruleId: string; isActive: boolean }) => Promise<AutomationRule>;
  isCreating: boolean;
  isUpdating: boolean;
  isDeleting: boolean;
  isToggling: boolean;
}
