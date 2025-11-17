import type { AutomationRule } from '../../types';

export interface AutomationRuleCardProps {
  rule: AutomationRule;
  onEdit: (ruleId: string) => void;
  onDelete: (ruleId: string) => void;
  onToggle: (ruleId: string, isActive: boolean) => void;
  isDeleting: boolean;
  isToggling: boolean;
  className?: string;
}
